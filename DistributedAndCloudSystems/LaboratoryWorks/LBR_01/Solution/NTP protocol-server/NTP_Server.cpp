#include <iostream>
#include <chrono>
#include <string>
#include <iomanip>
#include <ctime>
#include "Winsock2.h"
#include <windows.h>
#include "Errors.h"
#pragma warning( disable : 4996)

#pragma comment(lib, "WS2_32.lib")

using namespace std;

clock_t lastSync;
CRITICAL_SECTION csServerTime;

struct GETSINCHRO
{
	DWORD64 mTime;
};

struct SETSINCHRO
{
	__int64 corrTime;
};

struct NTP_packet
{
	CHAR head[4];
	DWORD32 RootDelay;
	DWORD32 RootDispersion;
	CHAR ReferenceIdentifier[4];

	DWORD32 RequestTimestamp[2];
	DWORD32 ReferenceTimestamp[2];
	DWORD32 OriginateTimestamp[2];
	DWORD32 TransmitTimestamp[2];

	DWORD32 KeyIdentifier;
	DWORD32 MessageDigest[4];
};

DWORD64 GetLocalUnixTime()
{
	return std::chrono::duration_cast<std::chrono::milliseconds>(std::chrono::system_clock::now().time_since_epoch()).count();
}

string FormatTime(DWORD64 unixTime) {
	time_t time = unixTime / 1000; 
	struct tm* timeInfo;
	timeInfo = localtime(&time);

	char buffer[30];
	sprintf(buffer, "%02d.%02d.%04d %02d.%02d.%02d.%03d",
		timeInfo->tm_mday, timeInfo->tm_mon + 1, timeInfo->tm_year + 1900,
		timeInfo->tm_hour, timeInfo->tm_min, timeInfo->tm_sec,
		(int)(unixTime % 1000));

	return string(buffer);
}

DWORD WINAPI SyncGlobalUnixTime(void* lpar)
{
	int h = CLOCKS_PER_SEC;	
	clock_t t = clock();	
	long d = (long)613608 * (long)3600;	
	time_t ttime; time(&ttime); 

	WSAData wsaData;
	SOCKET s;
	SOCKADDR_IN server;

	server.sin_family = AF_INET;
	server.sin_addr.s_addr = inet_addr("193.40.0.5");
	server.sin_port = htons(123);

	NTP_packet out_buf, in_buf;
	if (WSAStartup(MAKEWORD(2, 0), &wsaData) != 0) throw WSAGetLastError();

	while (true)
	{
		ZeroMemory(&out_buf, sizeof(out_buf));
		ZeroMemory(&in_buf, sizeof(in_buf));
		out_buf.head[0] = 0x1B;
		out_buf.head[1] = 0x00;
		out_buf.head[2] = 4;
		out_buf.head[3] = 0xEC;
		DWORD64 tms = 0, oms = 0;
		try {
			if ((s = socket(AF_INET, SOCK_DGRAM, NULL)) == INVALID_SOCKET) throw WSAGetLastError();

			DWORD timeout = 20000;
			setsockopt(s, SOL_SOCKET, SO_RCVTIMEO, (char*)&timeout, sizeof(DWORD));

			int lenout = 0, lenin = 0, lensockaddr = sizeof(server);
			clock_t qtime = clock();

			if ((lenout = sendto(s, (char*)&out_buf, sizeof(out_buf), NULL, (sockaddr*)&server, sizeof(server))) == SOCKET_ERROR)
				throw  SetErrorMsgText("Send vega: ", WSAGetLastError());
			if ((lenin = recvfrom(s, (char*)&in_buf, sizeof(in_buf), NULL, (sockaddr*)&server, &lensockaddr)) == SOCKET_ERROR)
				throw SetErrorMsgText("Recieve: ", WSAGetLastError());

			clock_t transmissionTime = clock() - qtime;
			DWORD64 localUnixTime = GetLocalUnixTime();

			in_buf.TransmitTimestamp[0] = ntohl(in_buf.TransmitTimestamp[0]) - d;
			in_buf.OriginateTimestamp[0] = ntohl(in_buf.OriginateTimestamp[0]) - d;
			in_buf.TransmitTimestamp[1] = ntohl(in_buf.TransmitTimestamp[1]);	
			in_buf.OriginateTimestamp[1] = ntohl(in_buf.OriginateTimestamp[1]);

			tms = (DWORD64)((1000.0 * ((double)(in_buf.TransmitTimestamp[1]) / (double)0xffffffff)) + (DWORD64)in_buf.TransmitTimestamp[0] * 1000);	
			oms = (DWORD64)((1000.0 * ((double)(in_buf.OriginateTimestamp[1]) / (double)0xffffffff)) + (DWORD64)in_buf.OriginateTimestamp[0] * 1000);	

			DWORD64 transmissionCorrection = (transmissionTime - ((DWORD64)tms - (DWORD64)oms)) / 2;
			tms = (DWORD64)tms + transmissionCorrection;

			GETSINCHRO* t = (GETSINCHRO*)lpar;
			EnterCriticalSection(&csServerTime);
			lastSync = clock();
			t->mTime = (DWORD64)tms;
			LeaveCriticalSection(&csServerTime);

			cout << "Sync with  NTP server" << endl;

			cout << "Local UNIX time: " << FormatTime(localUnixTime) << " Global time: " << FormatTime(tms) << endl;

			if (tms > localUnixTime)
			{
				cout << "The local time is " << tms - localUnixTime << " behind  of the global" << endl;
			}
			else
			{
				cout << "The local time is " << localUnixTime - tms << " ms ahead of the the global" << endl;
			}
			cout << endl;
			if (closesocket(s) == INVALID_SOCKET) throw WSAGetLastError();

			Sleep(10000);
		}
		catch (int e) {
			std::cout << "error:" << e << std::endl;
		}
		catch (string errorMsgText)
		{
			cout << errorMsgText;
		}

	}
	if (WSACleanup() == SOCKET_ERROR) throw WSAGetLastError();
	return 0;
}

int main()
{
	cout << "NTP syncronized time server started" << endl;

	InitializeCriticalSection(&csServerTime);
	GETSINCHRO ExTime;

	HANDLE hSyncUnixTime = CreateThread(0, 0, SyncGlobalUnixTime, &ExTime, 0, 0);

	try
	{
		SOCKET serverSocket;
		WSADATA wsaData;

		if (WSAStartup(MAKEWORD(2, 0), &wsaData) != 0)
			throw SetErrorMsgText("Startup: ", WSAGetLastError());

		if ((serverSocket = socket(AF_INET, SOCK_DGRAM, NULL)) == INVALID_SOCKET)
			throw SetErrorMsgText("Socket: ", WSAGetLastError());

		SOCKADDR_IN serverParameters;
		serverParameters.sin_family = AF_INET;
		serverParameters.sin_port = htons(2000);
		serverParameters.sin_addr.s_addr = INADDR_ANY;

		if (bind(serverSocket, (LPSOCKADDR)&serverParameters, sizeof(serverParameters)) == SOCKET_ERROR)
			throw SetErrorMsgText("Bind_Server: ", WSAGetLastError());

		while (true)
		{
			SOCKADDR_IN clientParameters;
			int clientParametersLength = sizeof(clientParameters);

			GETSINCHRO gs;
			if ((recvfrom(serverSocket, (char*)&gs, sizeof(gs), NULL, (sockaddr*)&clientParameters, &clientParametersLength)) == SOCKET_ERROR)
				throw SetErrorMsgText("RecvFrom: ", WSAGetLastError());

			SETSINCHRO ss;

			EnterCriticalSection(&csServerTime);
			int delta = clock() - lastSync;

			ss.corrTime = ExTime.mTime + delta - gs.mTime;
			LeaveCriticalSection(&csServerTime);

			sendto(serverSocket, (char*)&ss, sizeof(ss), 0, (sockaddr*)&clientParameters, sizeof(clientParameters));
		}

		if (closesocket(serverSocket) == SOCKET_ERROR)
			throw SetErrorMsgText("close socket: ", WSAGetLastError());
		if (WSACleanup() == SOCKET_ERROR)
			throw SetErrorMsgText("Cleanup: ", WSAGetLastError());
	}
	catch (string errorMsgText)
	{
		cout << endl << errorMsgText;
	}

	WaitForSingleObject(hSyncUnixTime, INFINITE);
	DeleteCriticalSection(&csServerTime);
	return 0;
}
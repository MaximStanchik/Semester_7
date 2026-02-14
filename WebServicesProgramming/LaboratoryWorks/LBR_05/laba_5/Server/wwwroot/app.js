class CalculatorApp {
    constructor() {
        this.connection = null;
        this.isConnected = false;

        this.initializeElements();
        this.attachEventListeners();

        this.connect();
    }

    initializeElements() {
        this.xValue = document.getElementById('xValue');
        this.yValue = document.getElementById('yValue'); 

        this.sumBtn = document.getElementById('sumBtn');
        this.subBtn = document.getElementById('subBtn');
        this.mulBtn = document.getElementById('mulBtn');
        this.divBtn = document.getElementById('divBtn');
        this.factBtn = document.getElementById('factBtn');
        this.connectBtn = document.getElementById('connectBtn');
        this.disconnectBtn = document.getElementById('disconnectBtn');

        this.result = document.getElementById('result');
        this.status = document.getElementById('status');
    }

    attachEventListeners() {
        this.connectBtn.addEventListener('click', () => this.connect());
        this.disconnectBtn.addEventListener('click', () => this.disconnect());

        this.sumBtn.addEventListener('click', () => this.calculate('SUM'));
        this.subBtn.addEventListener('click', () => this.calculate('SUB'));
        this.mulBtn.addEventListener('click', () => this.calculate('MUL'));
        this.divBtn.addEventListener('click', () => this.calculate('DIV'));
        this.factBtn.addEventListener('click', () => this.calculate('FACT'));

        [this.xValue, this.yValue].forEach(input => {
            input.addEventListener('keypress', (e) => {
                if (e.key === 'Enter') {
                    this.calculate('SUM');
                }
            });
        });

        this.xValue.addEventListener('keypress', (e) => {
            if (e.key === 'Enter') {
                this.calculateFactorial();
            }
        });
    }

    async connect() {
        try {
            this.updateStatus('Connecting...', 'status-connecting');
            this.updateButtons();

            const baseUrl = window.location.origin;

            this.connection = new signalR.HubConnectionBuilder()
                .withUrl(`${baseUrl}/calculatorHub`)
                .withAutomaticReconnect()
                .build();

            this.connection.onclose(() => {
                this.isConnected = false;
                this.updateStatus('Disconnected', 'status-disconnected');
                this.updateButtons();
            });

            this.connection.onreconnecting(() => {
                this.updateStatus('Reconnecting...', 'status-connecting');
            });

            this.connection.onreconnected(() => {
                this.isConnected = true;
                this.updateStatus('Connected', 'status-connected');
                this.updateButtons();
            });

            await this.connection.start();
            this.isConnected = true;
            this.updateStatus('Connected', 'status-connected');
            this.updateButtons();

            this.showResult('Connection established successfully!', 'success');

        } 
        catch (error) {
            console.error('Connection failed:', error);
            this.updateStatus('Connection Failed', 'status-disconnected');
            this.showResult(`Connection failed: ${error.message}`, 'error');

            if (error.message.includes('negotiation')) {
                this.showResult('Negotiation failed. Check CORS configuration and server URL.', 'error');
            }
        }
    }

    disconnect() {
        if (this.connection) {
            this.connection.stop();
            this.isConnected = false;
            this.updateStatus('Disconnected', 'status-disconnected');
            this.updateButtons();
            this.showResult('Disconnected from server', 'info');
        }
    }

    updateButtons() {
        const operationButtons = [
            this.sumBtn, this.subBtn, this.mulBtn,
            this.divBtn, this.factBtn
        ];

        operationButtons.forEach(btn => {
            btn.disabled = !this.isConnected;
        });

        this.connectBtn.disabled = this.isConnected;
        this.disconnectBtn.disabled = !this.isConnected;
    }

    updateStatus(message, className) {
        this.status.textContent = message;
        this.status.className = className;
    }

    async calculate(operation) {
        if (!this.isConnected) {
            this.showResult('Please connect to the server first', 'error');
            return;
        }

        const x = parseFloat(this.xValue.value);
        const y = parseFloat(this.yValue.value);

        if (isNaN(x) || isNaN(y)) {
            this.showResult('Please enter valid numbers for X and Y', 'error');
            return;
        }

        try {
            this.showResult('Calculating...', 'info');

            if (operation === 'FACT') {
                const result = await this.connection.invoke(operation, x);
                this.showResult(`${operation}(${x}) = ${result}`, 'success');
                return;
            }

            const result = await this.connection.invoke(operation, x, y);
            this.showResult(`${operation}(${x}, ${y}) = ${result}`, 'success');

        } catch (error) {
            this.showResult(`Error: ${error.message}`, 'error');
        }
    }

    showResult(message, type) {
        this.result.textContent = message;
    }
}

document.addEventListener('DOMContentLoaded', () => {
    new CalculatorApp();
});
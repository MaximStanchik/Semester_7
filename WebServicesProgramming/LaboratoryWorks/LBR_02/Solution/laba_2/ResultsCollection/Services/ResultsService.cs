using Newtonsoft.Json;
using ResultsCollection.Interfaces;
using System.Collections.Concurrent;

namespace ResultsCollection.Services
{
    public class ResultsService : IResultsCollection
    {
        private readonly string _filePath;
        private Dictionary<int, string> _items;
        private int _nextId = 1;
        private readonly SemaphoreSlim _fileLock = new SemaphoreSlim(1, 1);
        private static readonly ConcurrentDictionary<string, SemaphoreSlim> _fileLocks = new();

        public ResultsService()
        {
            _filePath = Path.Combine(Directory.GetCurrentDirectory(), "result.json");
            _items = new Dictionary<int, string>();

            LoadFromFileAsync().GetAwaiter().GetResult();
        }

        public ReturnedModel Add(string value)
        {
            if (string.IsNullOrWhiteSpace(value))
                throw new ArgumentException("Value cannot be empty");

            _fileLock.Wait();
            try
            {
                var newItem = new ReturnedModel(_nextId, value);
                _items.Add(_nextId, value);
                _nextId++;
                _ = SaveToFileAsync(); 
                return newItem;
            }
            finally
            {
                _fileLock.Release();
            }
        }

        public ReturnedModel? Delete(int id)
        {
            _fileLock.Wait();
            try
            {
                if (!_items.TryGetValue(id, out var itemToDelete))
                    return null; 

                _items.Remove(id);
                _ = SaveToFileAsync();
                return new ReturnedModel(id, itemToDelete);
            }
            finally
            {
                _fileLock.Release();
            }
        }

        public Dictionary<int, string> GetAll()
        {
            _fileLock.Wait();
            try
            {
                return new Dictionary<int, string>(_items); 
            }
            finally
            {
                _fileLock.Release();
            }
        }

        public ReturnedModel? GetById(int id)
        {
            _fileLock.Wait();
            try
            {
                if (!_items.TryGetValue(id, out var result))
                    return null; 

                return new ReturnedModel(id, result);
            }
            finally
            {
                _fileLock.Release();
            }
        }

        public ReturnedModel? Update(int id, string value)
        {
            if (string.IsNullOrWhiteSpace(value))
                throw new ArgumentException("Value cannot be empty");

            _fileLock.Wait();
            try
            {
                if (!_items.ContainsKey(id))
                    return null; 

                _items[id] = value;
                _ = SaveToFileAsync();
                return new ReturnedModel(id, _items[id]);
            }
            finally
            {
                _fileLock.Release();
            }
        }

        private async Task LoadFromFileAsync()
        {
            await _fileLock.WaitAsync();
            try
            {
                Console.WriteLine($"Loading from: {_filePath}");
                Console.WriteLine($"File exists: {File.Exists(_filePath)}");

                if (!File.Exists(_filePath))
                {
                    _items = new Dictionary<int, string>();
                    _nextId = 1;
                    return;
                }

                var json = await File.ReadAllTextAsync(_filePath);
                Console.WriteLine($"JSON content: {json}");

                var data = JsonConvert.DeserializeObject<StorageModel>(json);
                if (data != null)
                {
                    _items = data.Items ?? new Dictionary<int, string>();
                    _nextId = data.NextId; 
                    Console.WriteLine($"Loaded {_items.Count} items, nextId: {_nextId}");
                }
                else
                {
                    _items = new Dictionary<int, string>();
                    _nextId = 1;
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error loading file: {ex.Message}");
                _items = new Dictionary<int, string>();
                _nextId = 1;
            }
            finally
            {
                _fileLock.Release();
            }
        }

        private async Task SaveToFileAsync()
        {
            await _fileLock.WaitAsync();
            try
            {
                var data = new StorageModel
                {
                    Items = _items,
                    NextId = _nextId 
                };
                var json = JsonConvert.SerializeObject(data, Formatting.Indented);

                var directory = Path.GetDirectoryName(_filePath);
                if (!Directory.Exists(directory))
                    Directory.CreateDirectory(directory!);

                await File.WriteAllTextAsync(_filePath, json);
                Console.WriteLine($"Saved {_items.Count} items to file, nextId: {_nextId}");
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error saving file: {ex.Message}");
            }
            finally
            {
                _fileLock.Release();
            }
        }
    }
}
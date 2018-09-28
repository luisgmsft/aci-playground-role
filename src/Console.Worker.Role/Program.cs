using System.Configuration;
using System.Data.OleDb;

namespace Console.Worker.Role
{
    class Program
    {
        static void Main(string[] args)
        {
            var argumentIndex = int.Parse(ConfigurationManager.AppSettings["ArgumentIndex"]);
            var localDataPath = ConfigurationManager.AppSettings["DataModelPath"];
            string identifier = null;

            if (args.Length == 0 || string.IsNullOrWhiteSpace(args?[argumentIndex]?? ""))
            {
                System.Console.WriteLine("Identifier parameter was not passed. Defaulting...");
                identifier = "0000-00000-0000000000-111111111";
            } else {
                System.Console.WriteLine($"Identifier parameter received: {args[0]}");
                identifier = args[0];
            }

            using (OleDbConnection sourceStore = new OleDbConnection(@"Provider=Microsoft.Jet.OLEDB.4.0;" + @"data source=" + localDataPath + ";"))
            {
                sourceStore.Open();

                OleDbCommand commandCountries = new OleDbCommand("SELECT * from Countries ORDER BY Country", sourceStore);
                using (OleDbDataReader readerCountries = commandCountries.ExecuteReader())
                {
                    while (readerCountries.Read())
                    {
                        var c = readerCountries
                            .GetValue(1)
                            .ToString()
                            .Trim()
                            .Replace("'", " ");
                        System.Console.WriteLine(
                            $"Country: {c}");
                    }
                }
            }

            System.Console.WriteLine($"Run identifier {identifier}.");
            System.Console.ReadLine();
        }
    }
}

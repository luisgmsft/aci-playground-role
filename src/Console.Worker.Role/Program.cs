using System.Configuration;

namespace Console.Worker.Role
{
    class Program
    {
        static void Main(string[] args)
        {
            int argumentIndex = int.Parse(ConfigurationManager.AppSettings["ArgumentIndex"]);

            if (args.Length == 0 || string.IsNullOrWhiteSpace(args?[argumentIndex]?? ""))
            {
                System.Console.WriteLine($"Identifier parameter was not passed.");
                System.Console.ReadLine();

                return;
            }

            System.Console.WriteLine($"Run identifier {args[argumentIndex]}.");
            System.Console.ReadLine();
        }
    }
}

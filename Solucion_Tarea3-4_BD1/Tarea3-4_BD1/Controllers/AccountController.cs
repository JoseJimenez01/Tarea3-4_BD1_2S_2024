using System.Data;
using System.Data.SqlClient;
using System.Threading.Tasks;
using Dapper;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Configuration;
using Tarea3BD1.Models;

namespace Tarea3BD1.Controllers
{
    public class AccountController : Controller
    {
        private readonly IConfiguration _configuration;

        public AccountController(IConfiguration configuration)
        {
            _configuration = configuration;
        }



        [HttpGet]
        public IActionResult Login()
        {
            return View();
        }

        [HttpPost]
        public async Task<IActionResult> Login(LoginViewModel model)
        {
            if (ModelState.IsValid)
            {
                string connectionString = _configuration.GetConnectionString("MyDbConnection");

                // Output the connection string for testing purposes
                Console.WriteLine($"Connection String: {connectionString}");


                using (SqlConnection connection = new SqlConnection(connectionString))
                {
                    try
                    {
                        await connection.OpenAsync();

                        var parameters = new DynamicParameters();
                        parameters.Add("@Username", model.Username, DbType.String);
                        parameters.Add("@Password", model.Password, DbType.String);
                        parameters.Add("@OutResulTCode", dbType: DbType.Int32, direction: ParameterDirection.Output);

                        var result = await connection.QueryAsync<LoginViewModel>(
                            "GetUserCredentials",
                            parameters,
                            commandType: CommandType.StoredProcedure);

                        int resultCode = parameters.Get<int>("@OutResulTCode");

                        // Check if the resultCode is successful
                        if (resultCode == 0)
                        {
                           
                            // var user = result.FirstOrDefault(u => u.Username == model.Username && u.Password == model.Password);
                            // Console.WriteLine($"User: {user.Username}");

                            HttpContext.Session.SetString("Username", model.Username);
                            
                            TempData["Username"] = HttpContext.Session.GetString("Username");
                            return RedirectToAction("Index", "Empleado");
                        }
                        else if (resultCode == 50006)
                        {
                            TempData["MensajeError"] = "Usuario y/o password invalidos";
                            return RedirectToAction("Login", "Account");
                        }
                    }
                    catch (Exception ex)
                    {
                        // Log exception and display error
                        ModelState.AddModelError("", "An error occurred while processing your request.");
                    }
                }
            }

            // If we got this far, something failed, redisplay form
            return View(model);
        }

        public IActionResult Logout()
        {
            // Clear the session
            HttpContext.Session.Clear();

            // Optionally: If you want to clear authentication cookies as well, you can do this:
            // await HttpContext.SignOutAsync(CookieAuthenticationDefaults.AuthenticationScheme);

            // Redirect to the login page or home page after logout
            return RedirectToAction("Login", "Account");
        }
    }
}

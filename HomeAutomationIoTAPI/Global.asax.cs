using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Http;
using System.Web.Routing;
using System.Configuration;
using Intel.eFactory.DataAccess;

namespace HomeAutomationIoTAPI
{
    public class WebApiApplication : System.Web.HttpApplication
    {
        protected void Application_Start()
        {
               GlobalConfiguration.Configure(WebApiConfig.Register);
            Intel.eFactory.DataAccess.Environment.Connections.Add("HomeAutomationIoT", ConfigurationManager.ConnectionStrings["HomeAutomationIoTdb"].ConnectionString);
            Intel.eFactory.DataAccess.Environment.Connections.DefaultConnection = "HomeAutomationIoT";
        }
    }
}

using Intel.eFactory.DataAccess;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;
using Newtonsoft.Json;
using System.Collections.Generic;

namespace HomeAutomationIoTAPI.Controllers
{
    [RoutePrefix("api")]
    public class TempGaugeController : ApiController
    {
        [HttpGet]
        [Route("TempGauge/{sensorName}/{location}/{experiment}/{temp:decimal}/{vccVoltage:decimal}")]
        public HttpResponseMessage RecordTemp(string sensorName, string location, string experiment, decimal temp, decimal vccVoltage)
        {
            DateTime start = DateTime.Now;

            var p = new Parameters()
        {
            { "sensorName", sensorName },
            { "location", location },
            { "experiment", experiment },
            { "value", temp },
            { "vccVoltage", vccVoltage }
        };
            int newTimeValue = Connect.Execute("uspDeviceLotValueInsert", p);

            HttpResponseMessage response;
            response = Request.CreateResponse(HttpStatusCode.OK, newTimeValue);
            return response;
        }

        [HttpGet]
        [Route("TempGauge/GetTemps")]
        public HttpResponseMessage GetTemps()
        {
            DataTable results = Connect.GetDataTable("uspDeviceLogValueSelectAll");

            HttpResponseMessage response;
            response = Request.CreateResponse(HttpStatusCode.OK, results);
            return response;
        }

        struct Temps
        {
            public DateTime name { get; set; }
            //public string name { get; set; }
            public double y { get; set; }
        };

 
        [HttpGet]
        [Route("TempGauge/GetTempsForChart")]
        public HttpResponseMessage GetTempsForChart()
        {
 
            DataTable results = Connect.GetDataTable("uspDeviceLogValueSelectForChart");
            var resultsArray = new List<Temps>();

            foreach (DataRow row in results.Rows)
            {
                //resultsArray.Add(new Temps { name = row["Updated"].ToString(), y = Convert.ToDouble(row["Value"]) });
                resultsArray.Add(new Temps { name = Convert.ToDateTime(row["Updated"].ToString()), y = Convert.ToDouble(row["Value"]) });
            }

            HttpResponseMessage response;
            response = Request.CreateResponse(HttpStatusCode.OK, JsonConvert.SerializeObject(resultsArray));
            return response;
        }

        [HttpGet]
        [Route("TempGauge/GetActiveClients")]
        public HttpResponseMessage GetActiveClients()
        {

            DataTable results = Connect.GetDataTable("uspDeviceLogValueGetActiveClients");

            HttpResponseMessage response;
            response = Request.CreateResponse(HttpStatusCode.OK, results);
            return response;
        }

        [HttpGet]
        [Route("TempGauge/GetExperiments")]
        public HttpResponseMessage GetExperiments()
        {

            DataTable results = Connect.GetDataTable("uspDeviceLogValueGetExperiments");

            HttpResponseMessage response;
            response = Request.CreateResponse(HttpStatusCode.OK, results);
            return response;
        }
    }
}

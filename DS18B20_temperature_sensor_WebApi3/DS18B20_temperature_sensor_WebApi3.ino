#include <ESP8266WiFi.h>
#include <Base64.h>
#include <OneWire.h>
#include <DallasTemperature.h>

//AP definitions
#define AP_SSID "haha"
#define AP_PASSWORD "7AB9B67E1E"
//#define AP_SSID "Eric_iPhone"
//#define AP_PASSWORD "erichaha1!"

#define EIOT_IP_ADDRESS  "192.168.0.90"  //home
#define EIOT_PORT        80
#define REPORT_INTERVAL 300 // 5 minutes
//#define REPORT_INTERVAL 60 // 1 minute
static const String SENSOR_NAME = "Outside";
//url += "Family_Room";
//url += "Downstairs_Hall";
//url += "Upstairs_Hall";
//url += "Outside";

static const String LOCATION = "Home_Outside";
//url += "Home_Family_Room";
//url += "Home_Downstairs_Hall";
//url += "Home_Upstairs_Hall";
//url += "Home_Outside";

static const String SOFTWARE_VERSION = "1.0.6";

ADC_MODE(ADC_VCC);

// Mapping of GPIO pin numbers to Numbers on the board
static const uint8_t D0   = 16;
static const uint8_t D1   = 5;
static const uint8_t D2   = 4;
static const uint8_t D3   = 0; //Onboard Red LED
static const uint8_t D4   = 2; //Onboard Blue LED
static const uint8_t D5   = 14;
static const uint8_t D6   = 12;
static const uint8_t D7   = 13;
static const uint8_t D8   = 15;
static const uint8_t D9   = 3;
static const uint8_t D10  = 1;

//OneWire oneWire(BLUE_LED);
OneWire oneWire(D5);
DallasTemperature DS18B20(&oneWire);

void setup() {
  Serial.begin(115200);
  Serial.println("");
  Serial.println("");
  Serial.print("Software Version: ");
  Serial.println(SOFTWARE_VERSION);
  Serial.print("turning on red led....");
  pinMode(D3, OUTPUT);
  digitalWrite(D3, LOW);

  Serial.println("");
  Serial.print("turning on blue led....");
  pinMode(D4, OUTPUT);
  digitalWrite(D4, LOW);

  Serial.println("");
  Serial.print("turning on external green LED....");
  pinMode(D7, OUTPUT);
  digitalWrite(D7, LOW);
  Serial.println();

  Serial.print("Opening one wire bus input....");
  Serial.println();
  digitalWrite(D5, HIGH);
  pinMode(D5, OUTPUT);
  Serial.println("One Wire complete....");

  wifiConnect();

  writeStatusLed();

  digitalWrite(D4, HIGH);  // turn off Blue onboard LED
  digitalWrite(D3, HIGH);  // turn off Red onboard LED
}

void loop() {
  float tempC;
  float tempF;
  
  do {
    DS18B20.requestTemperatures();
    tempC = DS18B20.getTempCByIndex(0);
    tempF = tempC * 1.8 + 32;
    Serial.print("Instant Temperature: ");
    Serial.print(tempF);
    Serial.print("F ");
    Serial.print(tempC);
    Serial.print("C ");
    Serial.println();
    delay(1000); //temp
  } while (tempC == 85.0 || tempC == (-127.0));

  sendTeperature(tempF);

  int cnt = REPORT_INTERVAL;

  while (cnt--)
    delay(1000);
}

void wifiConnect()
{
  int attempts = 0;
  Serial.println("Connecting to AP...");
  WiFi.begin(AP_SSID, AP_PASSWORD);
  while (WiFi.status() != WL_CONNECTED) {
    Serial.print("WiFi.status() = ");
    Serial.println(WiFi.status());
    //      WL_NO_SHIELD = 255,
    //      WL_IDLE_STATUS = 0,
    //      WL_NO_SSID_AVAIL = 1
    //      WL_SCAN_COMPLETED = 2
    //      WL_CONNECTED = 3
    //      WL_CONNECT_FAILED = 4
    //      WL_CONNECTION_LOST = 5
    //      WL_DISCONNECTED = 6
    String error = "ERROR: wifiConnect(): WiFi.status() = ";
    error += WiFi.status();
    writeStatusLedNotConnected(error, "wifiConnect()");
    //Serial.print(".");
    attempts ++;
    if (attempts >= 100) {
      writeStatusLedError("ERROR: wifiConnect(): Unable to connect to AP after 100 attempts", 300, 250, "wifiConnect()");
      attempts = 0;
      WiFi.disconnect();
      Serial.println("ERROR: wifiConnect(): attempting reconnect to WiFi");
      WiFi.begin(AP_SSID, AP_PASSWORD);
    }
  }

  Serial.println("WiFi connected");
  Serial.print("WiFi.status() = ");
  Serial.println(WiFi.status());
  Serial.print("IP address: ");
  Serial.println(WiFi.localIP());
  Serial.print("WiFi.RSSI() signal strength = ");
  Serial.println(WiFi.RSSI());
}

void writeStatusLed()
{
  Serial.println();
  Serial.println("starting writeStatusLed....");
  int i = 0;

  do {
    delay(90);
    digitalWrite(D7, LOW);
    delay(90);
    digitalWrite(D7, HIGH);
    i ++;
  } while (i < 4);
}

void writeStatusLedNotConnected(String error, String senderFunction){
  Serial.print("ERROR: writeStatusLedNotConnected(): Sender Function: ");
  Serial.print(senderFunction);
  Serial.print(" Error: ");
  Serial.println(error);

  int i = 0;
  do {
    delay(50);
    digitalWrite(D3, LOW);
    delay(50);
    digitalWrite(D3, HIGH);
    i++;
  } while (i < 2);

  Serial.println("Ending writeStatusLedNotConnected()");
  Serial.println("");
}

void writeStatusLedError(String error, int times, int delayMils, String senderFunction)
{
  Serial.print("ERROR: writeStatusLedError(): Sender Function: ");
  Serial.print(senderFunction);
  Serial.print(" Error: ");
  Serial.println(error);

  int i = 0;
  do {
    delay(delayMils);
    digitalWrite(D7, LOW);
    digitalWrite(D3, LOW);
    digitalWrite(D4, LOW);
    delay(delayMils);
    digitalWrite(D7, HIGH);
    digitalWrite(D3, HIGH);
    digitalWrite(D4, HIGH);
    i++;
  } while (i < times);

  Serial.println("Ending writeStatusLedError()");
  Serial.println("");
}

void writeStatusLedComplete()
{
  Serial.println("starting writeStatusLedComplete....");

  digitalWrite(D7, LOW);
  delay(500);

  int i = 0;
  do {
    delay(150);
    digitalWrite(D7, HIGH);
    delay(150);
    digitalWrite(D7, LOW);
    i ++;
  } while (i < 5);

  digitalWrite(D7, HIGH);
}

void sendTeperature(float temp)
{
  writeStatusLed();
  if (WiFi.status() != WL_CONNECTED) {
    Serial.println("ERROR SendTemperature(): WiFi.Status() = " + WiFi.status());
    Serial.println("ERROR: SendTemperature(): Not connected to WIFI, attempting to reconnect");
    WiFi.disconnect();
    wifiConnect();
  }

  int attempts = 0;
  WiFiClient client;
  while (!client.connect(EIOT_IP_ADDRESS, EIOT_PORT)) {
    Serial.println("ERROR: SendTemperature(): WiFiClient connection failed");
    //writeStatusLedError("Client connect failed in sendTemperature", 8, 100, "sendTemperature()");
    writeStatusLedNotConnected("Client connect failed in sendTemperature", "sendTemperature()");
    attempts ++;
    if (attempts >= 20) {
      writeStatusLedError("Unable to connect to AP after 100 attempts", 300, 250, "sendTemperature");
      attempts = 0;
    }
  }

  Serial.println("sendTeperature(): Connect to API complete");
  Serial.print("sendTeperature(): WiFi.RSSI() signal strength = ");
  Serial.println(WiFi.RSSI());

  double vccraw = ESP.getVcc();
  double vcc = vccraw / 1000;
  Serial.print("Vcc voltage is: ");
  Serial.println(vcc);

  Serial.print("Memory alloc Free Heap: ");
  Serial.println(ESP.getFreeHeap());
  
  String url = "";
  url += "http://server1/HomeAutomationIoTAPI/api/TempGauge/";   // Home1/Family_Room/Multi-sensor%20Temp%20Variation/";  latest
  // url += "http://server1/HomeAutomationIoTAPI/api/TempGauge/Home1/Family_Room/Multi-sensor%20Temp%20Variation/";
  //old 1 url += "http://a250rlover.ddns.me/HomeAutomationIoTAPI/api/TempGauge/Home1/Family_Room/Multi-sensor%20Temp%20Variation/";  //external
  url += SENSOR_NAME;
  url += "/";
  url += LOCATION;
  url += "/";
  url += "Multi-sensor%20Temp%20Variation";
  url += "/";
  url += temp;
  url += "/";
  url += vcc;
  url += "/";
  url += WiFi.RSSI();
  url += "/";
  url += ESP.getFreeHeap();
  url += "/";
  url += SOFTWARE_VERSION;
  url += "/";

  Serial.print("GET data to URL: ");
  Serial.println(url);

  //  client.print(String("GET ") + url + " HTTP/1.1\r\n" +
  //              "Host: " + String(EIOT_IP_ADDRESS) + "\r\n");

  client.print(String("GET ") + url + " HTTP/1.1\r\n" +
               "Host: " + String(EIOT_IP_ADDRESS) + "\r\n" +
               "Connection: close\r\n" +
               //              "Authorization: Basic " + unameenc + " \r\n" +
               "Content-Length: 0\r\n" +
               "\r\n");


  //delay(3000);
  int x = 0;
  while (client.available()) {
    String line = client.readStringUntil('\r');
    Serial.println(x);
    Serial.println("");
    Serial.println(line);
    x ++;
  }

  Serial.println("");
  writeStatusLedComplete();
  Serial.println();

  client.flush();
  client.stop();
}



# App-Template
This template includes DeeplinkHandler, DeeplinkParser, NotificationHandler and FirebaseRemoteConfigManager

Let's explain these classes

## DeepLinkParser
This class parsing deeplink data with url and return our DeepLinkModel 
with 
```
protocol DeepLinkParserProtocol: AnyObject {
    func parse(for url: URL?) -> Result<DeepLinkModel>
}
```
this parse function is getting host and parameters from url to decide deeplinktype and return our DeepLink model with type and parameter

## DeepLinkHandlerManager
This class is saving our parsed DeepLink model we will use this model inside our mainViewController or tabbar it depends on your app requirements
with handledeeplink methods parsing with url or notification data and then saving data to our pendingDeepLinkModel
Also after the redirect/navigation we should call clearPendingDeepLink

## NotificationManager
When notification received to our phone and user clicked notification this class will send data to deeplinkhandler and then deep link handler will parse this data to our DeepLink model and deeplinkHandler save this data









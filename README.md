# Swan-Weather

To the reviewer, if you decide this code is not good enough, could you please give a constructive feedback so I can learn something and won't be a dumb programmer forever? I don't need a comprehensive list; just a small key information for me to improve upon, rather than just sayin no. Thank you. Edgar

# Walkthrough

From the brief I chose Open Weather Map api to show a list of nearby locations, and a search facility to locate any spot in the world. It then fetches data to the OWM service to collect the current temperature, icon reference, weather state, and minimum temperature. I intended to display the forecasts but didn’t have enough time.

The OWM documentation recommends to search by city id to avoid ambiguity. But in order to search, we need the list of ids first. So I decided to store all 200K id’s to disk and install as part of the bundle, because the API to search by city name can return completely unrelated data. I chose Realm as the persistent store because it is very fast and optimised and when used with the search bar filter, there is no lag or delay. The list of city id’s are stored as Spot objects and are imported by the SpotService on installation of the app.

I organised the view controllers using the Model-View-ViewModel (MVVM) design pattern. The models are derived from Realm objects and are direct mapping of the OWM schema. You will see there are two view controllers namely CitiesViewController and CityViewController. These view controllers have no business logics and only handle UIKit objects needed to run the app. Each view controller has a corresponding view models which as you may observe do not import UIKit. A characteristic of the MVVM pattern where there is no dependency on the platform used. The use of MVVM is also a very flexible and highly maintainable pattern. It also facilitate ease of unit tests. With this I created test specs for each view model and services. I also used RxSwift to observe changes between the view model and the view controllers. An alternative to this observation pattern is KVO which has boiler plate code and is less elegant. The OpenWeatherMapService uses Alamofire to asynchronously fetch the data from the service along with a flexible Router that formulates the URL string.

End

//
//  InstaStatsWidget.swift
//  InstaStatsWidget
//
//  Created by Yaseen Mallick on 08/01/21.
//

import WidgetKit
import SwiftUI
import Intents
import SDWebImageSwiftUI


struct Model: TimelineEntry {
    var date: Date
    var widgetData = InstaData.init(logging_page_id: "", graphql: GraphQLData.init(user: UserData.init(biography: "", edge_followed_by: FollowerData.init(count: 0), edge_follow: FollowingData.init(count: 0), full_name: "", profile_pic_url_hd: "", username: "")))
}

struct InstaData: Decodable {
    var logging_page_id: String
    var graphql: GraphQLData
}

struct GraphQLData: Decodable {
    var user: UserData
}

struct UserData: Decodable {
    var biography: String
    var edge_followed_by: FollowerData
    var edge_follow: FollowingData
    var full_name: String
    var profile_pic_url_hd: String
    var username: String
}

struct FollowerData: Decodable {
    var count: Int
}

struct FollowingData: Decodable {
    var count: Int
}

// Creating Provider For Providing Data For Widget....

struct Provider : TimelineProvider {
    //public typealias Entry = Model
    
    func getSnapshot(in context: Context, completion: @escaping (Model) -> Void) {
        
        // inital snapshot....
        // or loading type content....
        
        let loadingData = Model(date: Date(), widgetData: InstaData(logging_page_id: "", graphql: GraphQLData(user: UserData(biography: "", edge_followed_by: FollowerData(count: 0), edge_follow: FollowingData(count: 0), full_name: "", profile_pic_url_hd: "", username: ""))))
        
        completion(loadingData)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<Model>) -> Void) {
        
        // parsing json data and displaying....
        
        load { (modelData) in
            
            let date = Date()
            
            let data = Model(date: date, widgetData: modelData)
            
            // creating Timeline...
            
            // reloading data every 1 Hours...
            
            let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: date)!
            //.after(nextUpdate)
            let timeline = Timeline(entries: [data], policy: .after(nextUpdate))
            print("Test")
            
            completion(timeline)
        }
    }
    
    
    func placeholder(in context: Context) -> Model {
        
        // inital snapshot....
        // or loading type content....
        
        let loadingData = Model(date: Date(), widgetData: InstaData(logging_page_id: "", graphql: GraphQLData(user: UserData(biography: "", edge_followed_by: FollowerData(count: 0), edge_follow: FollowingData(count: 0), full_name: "", profile_pic_url_hd: "", username: ""))))
        
        return loadingData
    }
    
}

struct InstaStatsWidgetEntryView : View {
    //var entry: Provider.Entry
    var data: Model
    @State var ProfilePic = UserDefaults.standard.object(forKey: "ProfilePic")
    @State var NewFollowerCount = UserDefaults.standard.integer(forKey: "NewFollowerCount")
    
    @State var SharedFollowerCount = UserDefaults(suiteName: "group.InstaStats")!.integer(forKey: "SharedFollowerCount")
    
    @State var SharedProfilePic = UserDefaults(suiteName: "group.InstaStats")!.object(forKey: "SharedProfilePic")
    
    @State var Sharedusername = UserDefaults(suiteName: "group.InstaStats")!.object(forKey: "Sharedusername")
    
    @State var SharedFullName = UserDefaults(suiteName: "group.InstaStats")!.object(forKey: "SharedFullName")

    var body: some View {
        
        ZStack {
            Rectangle().frame(width: 250, height: 250).foregroundColor(.clear).background(LinearGradient(gradient: Gradient(colors: [Color(#colorLiteral(red: 0.5725490451, green: 0.323955467, blue: 0.1386560305, alpha: 1)),Color(#colorLiteral(red: 0.8137346179, green: 0.2270152048, blue: 0.5532511853, alpha: 1)),Color(#colorLiteral(red: 0.3647058904, green: 0.06666667014, blue: 0.9686274529, alpha: 1)),Color(#colorLiteral(red: 0.1764705926, green: 0.01176470611, blue: 0.5607843399, alpha: 1))]), startPoint: .topLeading, endPoint: .bottomTrailing))
            Rectangle().frame(width: 153, height: 150).foregroundColor(.clear).background(Color(#colorLiteral(red: 0.7422684585, green: 0.7422684585, blue: 0.7422684585, alpha: 1))).cornerRadius(20).offset(x: 0, y: 100)
            
            VStack {
                WebImage(url: URL(string: SharedProfilePic as? String ?? ""))
                    .resizable()
                    .placeholder(Image(systemName: "person.crop.circle"))
                    .transition(.fade(duration: 0.5))
                    .scaledToFit()
                    .frame(width: 50, height: 50, alignment: .center)
                    .clipShape(Circle())
                    .shadow(color: Color(#colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)), radius: 5, x: -5, y: 5)
                    .offset(y:3)
                
                Text((SharedFullName as! String) )
                
                VStack {
                    Text("Followers")
                        .font(.system(size: 12))
                        .padding(.vertical,1)
                        .foregroundColor(.gray)
                    
                    Text(SharedFollowerCount as NSObject,formatter: NumberFormatter.format)
                        .font(.system(size: 20))
                        .fontWeight(.semibold)
                        .foregroundColor(.black)
                        .shadow(color: Color(#colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)), radius: 5, x: -5, y: 5)
                    
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 2)
                .background(Color.white)
                .cornerRadius(10)
                .clipped()
                .shadow(color: Color(#colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)), radius: 12, x: -5, y: 5)

            }

        }

    }
    
}

@main
struct InstaStatsWidget: Widget {
    let kind: String = "InstaStatsWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "Graph", provider: Provider()) { data in
            InstaStatsWidgetEntryView(data: data)
        }
        .configurationDisplayName("InstaStats Widget")
        .description("Cyka Blyat its my first Widget")
    }
}

extension NumberFormatter {
    static var format: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter
    }
}

func load(completion: @escaping (InstaData)-> ()) {
    
    let username = UserDefaults.standard.object(forKey: "FullName") as? String ?? ""
    
    let sharedURL = UserDefaults(suiteName: "group.InstaStats")!.object(forKey: "SharedURL")
    print("This is from shared",sharedURL ?? "WTF")
    
    var FullName: String = ""
    var NewFollowerCount: Int = 0
    var ProfilePic: String = ""
    
    guard let url = URL(string: sharedURL as? String ?? "") else {
        print("Invalid URL")
        return
    }
    
    URLSession.shared.dataTask(with: url) {(data,response,error) in
        
        do {
            
            if let d = data {
                
                let instadata = try JSONDecoder().decode(InstaData.self, from: d)
                
                DispatchQueue.main.async {
                    
                    //print(instadata)

                    print("Updated")
                    completion(instadata)
                    
                    NewFollowerCount = instadata.graphql.user.edge_followed_by.count
                    //print(NewFollowerCount)
                    UserDefaults.standard.set(NewFollowerCount, forKey: "NewFollowerCount")
                    UserDefaults(suiteName: "group.InstaStats")!.set(NewFollowerCount, forKey: "SharedFollowerCount")
                    
                    FullName = instadata.graphql.user.full_name
                    UserDefaults.standard.set(FullName, forKey: "FullName")
                    UserDefaults(suiteName: "group.InstaStats")!.set(FullName, forKey: "SharedFullName")
                    
                    UserDefaults.standard.set(username, forKey: "username")
                    UserDefaults(suiteName: "group.InstaStats")!.set(username, forKey: "Sharedusername")
                    
                    ProfilePic = instadata.graphql.user.profile_pic_url_hd
                    UserDefaults.standard.set(ProfilePic, forKey: "ProfilePic")
                    UserDefaults(suiteName: "group.InstaStats")!.set(ProfilePic, forKey: "SharedProfilePic")
                    
                    UserDefaults.standard.synchronize()
                    
                }
                
            }else {
                print("No Data")
            }
            
        } catch let jsonError as NSError {
            print("\(jsonError.localizedDescription)")
            print ("Can't Decode Data")
            YouFuckedUp()
        }
        
    }.resume()
    
}

func YouFuckedUp() {
    let date = Date()
    UserDefaults.standard.set(date, forKey: "LastRefreshed")
    UserDefaults.standard.synchronize()
    print("You are now fucked up please wait 24 hours to get fucked up again")
}

func StillFuckedUp() -> Bool {
    guard let lastRefreshDate = UserDefaults.standard.object(forKey: "LastRefreshed") as? Date else {
        return true
    }

    if let diff = Calendar.current.dateComponents([.hour], from: lastRefreshDate, to: Date()).hour, diff >= 24 {
        print("You are now safe")
        return true
    } else {
        print("Still FuckedUp")
        return false
    }
    
}

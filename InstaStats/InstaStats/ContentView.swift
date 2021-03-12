//
//  ContentView.swift
//  InstaStats
//
//  Created by Yaseen Mallick on 29/12/20.
//

import WidgetKit
import SwiftUI
import CoreData
import SDWebImageSwiftUI

struct ContentView: View {
    
    @ObservedObject var fetcher = InstaDataFetcher()
    @State var LoggingStatus = isLoggedIn()
    @State var refresh = Refresh(started: false, released: false)
    
    var body: some View {
        
        if LoggingStatus {
            
            ZStack {
                
                Rectangle().frame(width: 380, height: 1500).foregroundColor(.clear).background(LinearGradient(gradient: Gradient(colors: [Color(#colorLiteral(red: 0.5725490451, green: 0.323955467, blue: 0.1386560305, alpha: 1)),Color(#colorLiteral(red: 0.8137346179, green: 0.2270152048, blue: 0.5532511853, alpha: 1)),Color(#colorLiteral(red: 0.3647058904, green: 0.06666667014, blue: 0.9686274529, alpha: 1)),Color(#colorLiteral(red: 0.1764705926, green: 0.01176470611, blue: 0.5607843399, alpha: 1))]), startPoint: .topLeading, endPoint: .bottomTrailing))
                
                ScrollView(.vertical, showsIndicators: false, content: {
                    
                    GeometryReader { reader -> AnyView in
                        
                        DispatchQueue.main.async {
                            
                            if refresh.startOffset == 0 {
                                refresh.startOffset = reader.frame(in: .global).minY
                                
                            }
                            
                            refresh.offset = reader.frame(in: .global).minY
                            
                            if refresh.offset - refresh.startOffset > 70 && !refresh.started {
                                
                                let impactHeavy = UIImpactFeedbackGenerator(style: .heavy)
                                impactHeavy.impactOccurred()
                                
                                refresh.started = true
                                
                            }
                            
                            if refresh.startOffset == refresh.offset && refresh.started && !refresh.released {
                                
                                if StillNotFuckedUp() && CanRefresh() {
                                    
                                    self.fetcher.username = UserDefaults.standard.object(forKey: "username") as! String
                                    self.fetcher.load()
                                    UpdateRefrences()
                                    AppendLogs()
                                    print(GetLogs())
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.5 ) {
                                        SetRefresh()
                                    }
                                } else {
                                    print("Can't Refresh")
                                }
                                
                                UpdateFunc()
                                
                                let impactHeavy = UIImpactFeedbackGenerator(style: .heavy)
                                impactHeavy.impactOccurred()
                                
                                withAnimation(Animation.linear) {
                                    refresh.released = true
                                }
                                
                            }
                            
                            if refresh.startOffset == refresh.offset && refresh.started && refresh.released && refresh.invalid {
                                refresh.invalid = false
                                UpdateFunc()
                            }
                            
                        }
                        return AnyView(Color.black.frame(width: 0, height: 0))
                        
                    }.frame(width: 0, height: 0)
                   
                    ZStack {
                        
                        if refresh.started && refresh.released {
                            
                            ProgressView()
                                .scaleEffect(1.5)
                                .offset(y: -350)
                                
                        }
                        else {
                            Image(systemName: "arrow.down")
                                .font(.system(size: 20, weight: .heavy))
                                .foregroundColor(.gray)
                                .rotationEffect(.init(degrees: refresh.started ? 180 : 0))
                                .offset(y: -398)
                                .animation(.easeIn)
                        }
                        
                        VStack {
                            InstaDataView(LoggingStatus: self.$LoggingStatus)
                                .onAppear(perform: {
                                    if StillNotFuckedUp() {
                                        self.fetcher.username = UserDefaults.standard.object(forKey: "username") as! String
                                        self.fetcher.load()
                                        UpdateRefrences()
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5 ) {
                                            SetRefresh()
                                        }
                                    } else {
                                        print(" Can't Auto Refresh ")
                                    }
                                })
                        }
                        
                        if refresh.released && StillNotFuckedUp() && CanRefresh() {
                            Text("  Account Refreshing...  ")
                                .font(.headline)
                                .padding(.vertical, 10)
                                .foregroundColor(Color(#colorLiteral(red: 0.8609973575, green: 0.8609973575, blue: 0.8609973575, alpha: 1)))
                                .background(Color(#colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)))
                                .cornerRadius(10)
                                .offset(x: 0, y: 250)
                        }
                        
                        if !StillNotFuckedUp() {
                            if refresh.released {
                                VStack {
                                    Text(" You are now on Cooldown ")
                                        .font(.headline)
                                    Text(" Please wait 24 hours to try Again ")
                                }
                                .padding(.vertical, 10)
                                .foregroundColor(Color(#colorLiteral(red: 0.8609973575, green: 0.8609973575, blue: 0.8609973575, alpha: 1)))
                                .background(Color(#colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)))
                                .cornerRadius(10)
                                .offset(x: 0, y: 250)
                            }
                        }
                        
                        if !CanRefresh() {
                            if refresh.released {
                                VStack {
                                    Text("Hold on Dude! , Take a break ")
                                        .font(.headline)
                                    Text(" Please wait 30 Seconds")
                                }
                                .padding(.all, 10)
                                .foregroundColor(Color(#colorLiteral(red: 0.8609973575, green: 0.8609973575, blue: 0.8609973575, alpha: 1)))
                                .background(Color(#colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)))
                                .cornerRadius(10)
                                .offset(x: 0, y: 250)
                            }
                        }
                        
                    }
                    
                })
            }
            

        } else {
            SearchUser(fetcher: self.fetcher, LoggingStatus: self.$LoggingStatus)
        }
        
    }
    
    func make_released_false() {
        refresh.released = false
    }
    
    func UpdateFunc() {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5 ) {
            withAnimation(Animation.linear) {
                
                if refresh.startOffset == refresh.offset {
                    refresh.released = false
                    refresh.started = false
                }
                else{
                    refresh.invalid = true
                }
  
            }
            
        }
        
    }
    
    struct Refresh {
        var startOffset: CGFloat = 0
        var offset: CGFloat = 0
        var started: Bool = false
        var released: Bool = false
        var invalid: Bool = false
    }

}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .preferredColorScheme(.dark)
    }
}

struct InstaDataView: View {
    
    @ObservedObject var fetcher = InstaDataFetcher()
    
    @Binding var LoggingStatus: Bool
    
    var ProfilePic = UserDefaults.standard.object(forKey: "ProfilePic")

    var FollowersCount = UserDefaults.standard.object(forKey: "FollowersCount")
    
    var NewFollowerCount = UserDefaults.standard.integer(forKey: "NewFollowerCount")
    
    var body: some View {
        
        ZStack {
            
            Rectangle().frame(width: 375, height: 1500).foregroundColor(.clear).background(Color(#colorLiteral(red: 0.7422684585, green: 0.7422684585, blue: 0.7422684585, alpha: 1))).cornerRadius(40).offset(x: 0, y: 820)

            Button(action: {
                LoggedOut()
                self.LoggingStatus = false
            }) {
                Text("   Logout   ")
                    .fontWeight(.semibold)
                    .padding(.all,8)
                    .foregroundColor(Color.black)
                    .background(Color.red)
                    .cornerRadius(40)
            }.offset(x: 0, y: 356)
            
            VStack {

                WebImage(url: URL(string: ProfilePic as? String ?? ""))
                    .resizable()
                    .placeholder(Image(systemName: "person.crop.circle"))
                    .transition(.fade(duration: 0.5))
                    .scaledToFit()
                    .frame(width: 150, height: 150, alignment: .center)
                    .clipShape(Circle())
                    .shadow(color: Color(#colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)), radius: 20, x: -10, y: 10)
                
                Text(UserDefaults.standard.object(forKey: "FullName") as? String ?? "")
                    .font(.title)
                    .padding()
                
                VStack {
                    
                    Text("Followers")
                        .padding(.all,1)
                        .foregroundColor(.gray)
                    
                    Text(NewFollowerCount as NSObject,formatter: NumberFormatter.format)
                        .font(.system(size: 60))
                        .fontWeight(.semibold)
                        .foregroundColor(.black)
                        .shadow(color: Color(#colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)), radius: 10, x: -10, y: 10)
                    
                    HStack(spacing: 130) {
                        
                        HStack {
                            Image(systemName: "arrowtriangle.up.fill")
                                .foregroundColor(.green)
                            
                            Text(GetGains() as NSObject,formatter: NumberFormatter.format)
                                .foregroundColor(.green)
                            
                        }
                        
                        HStack {
                            
                            Image(systemName: "arrowtriangle.down.fill")
                                .foregroundColor(.red)
                            
                            Text(GetLoss() as NSObject,formatter: NumberFormatter.format)
                                .foregroundColor(.red)
                            
                        }
                        
                    }.padding(3)
                    
                }
                .padding(20)
                .background(Color.white)
                .cornerRadius(15)
                .clipped()
                .shadow(color: Color(#colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)), radius: 25, x: -15, y: 15)
            
                LogView()
                    .offset(x: 0, y: -525)
                
            }
            
            
        }.ignoresSafeArea(edges: .all)
        
    }
    
}

struct SearchUser: View {
    
    @ObservedObject var fetcher = InstaDataFetcher()
    @State var username = ""
    @State var wait = false
    @Binding var LoggingStatus: Bool
    
    var body: some View {
        
        ZStack {
            
            LinearGradient(gradient: Gradient(colors: [Color(#colorLiteral(red: 0.5725490451, green: 0.323955467, blue: 0.1386560305, alpha: 1)),Color(#colorLiteral(red: 0.8137346179, green: 0.36932347, blue: 0.6237416239, alpha: 1)),Color(#colorLiteral(red: 0.1764705926, green: 0.01176470611, blue: 0.5607843399, alpha: 1))]), startPoint: .topLeading, endPoint: .bottomTrailing)
            
            if (wait){
                ProgressView()
                    .scaleEffect(1.5)
                    .offset(y: -65)
            }
            
            HStack {

                TextField("username", text: self.$username)
                    .padding(.horizontal , 15)
                    .frame(height: 35.0)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color(#colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)).opacity(1.0), lineWidth: 1)
                    )
                    .autocapitalization(.none)
                    .padding(.leading,60)
                
                Button(action: {
                    self.fetcher.username = self.username
                    self.wait.toggle()
                    LoadData()
                    SetLogs()
                    waitfunc()
                    
                }) {
                    Image(systemName: "magnifyingglass")
                        .frame(width: 45, height: 45).padding(.trailing,40)
                    
                }
                .disabled(self.username.isEmpty)
                
            }
            .padding(.horizontal)
            
        }
        .ignoresSafeArea(edges: .all)
        
    }
    
    func LoadData() {
        
        UserDefaults.standard.set(self.username, forKey: "username")
        UserDefaults(suiteName: "group.InstaStats")!.set(self.username, forKey: "SharedUserName")
        UserDefaults.standard.synchronize()
        
        self.fetcher.load()
        
    }
    
    func waitfunc() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 5 ) {
            
            SetRefrenceFollowerCount(Refrence_FollowerCount: self.fetcher.NewFollowerCount)
            SetLogRefrenceFollowerCount(Log_Refrence_FollowerCount: self.fetcher.NewFollowerCount)
            SetRefrenceDate()
            
            self.wait = false
            finishedLoggedIn()
            self.LoggingStatus = true
            
            print(GetRefrenceFollowerCount())
            
        }
    }
    
}

func finishedLoggedIn() {
    UserDefaults.standard.set(true, forKey: "isLoggedIn")
    UserDefaults.standard.synchronize()
}

func LoggedOut() {
    
    let username = ""
    let fullname = ""
    let NewFollowerCount = 0
    let profilepic = ""
    
    UserDefaults.standard.set(username, forKey: "username")
    UserDefaults(suiteName: "group.InstaStats")!.set(username, forKey: "Sharedusername")
    
    UserDefaults.standard.set(fullname, forKey: "FullName")
    UserDefaults(suiteName: "group.InstaStats")!.set(fullname, forKey: "SharedFullName")
    
    UserDefaults.standard.set(NewFollowerCount, forKey: "NewFollowerCount")
    UserDefaults(suiteName: "group.InstaStats")!.set(NewFollowerCount, forKey: "SharedFollowerCount")
    
    UserDefaults.standard.set(profilepic, forKey: "ProfilePic")
    UserDefaults(suiteName: "group.InstaStats")!.set(profilepic, forKey: "SharedProfilePic")
    
    SetRefrenceFollowerCount(Refrence_FollowerCount: 0)
    
    UserDefaults.standard.set(false, forKey: "isLoggedIn")
    
    UserDefaults.standard.synchronize()
    
    
}

func isLoggedIn() -> Bool {
    return UserDefaults.standard.bool(forKey: "isLoggedIn")
}

extension NumberFormatter {
    static var format: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter
    }
}

public class InstaDataFetcher: ObservableObject {
    
    @Published var data: InstaData?
    
    var BaseUrl = "https://www.instagram.com/"
    
    @Published var username: String = ""
    
    @Published var FullName: String = ""
    @Published var NewFollowerCount: Int = 0
    
    @Published var ProfilePic: String = ""
    
    var query = "/?__a=1"
    
    //let TestSharedURL = "https://run.mocky.io/v3/117bf7b2-ff50-4f8d-8ac0-76b7e9410c12"
    
    //let TestSharedURL = "https://run.mocky.io/v3/b5143afc-fb0b-4aa0-a542-616f1ae17b73"
    
    let TestSharedURL = "https://api.mocki.io/v1/41395188"
    
    //https://run.mocky.io/v3/117bf7b2-ff50-4f8d-8ac0-76b7e9410c12
    //https://run.mocky.io/v3/b5143afc-fb0b-4aa0-a542-616f1ae17b73
    
    func load() {
        
        //guard let url = URL(string: BaseUrl + username + query) else {
        //    print("Invalid URL")
        //    return
        //}
        
        guard let url = URL(string: TestSharedURL) else {
            print("Invalid URL")
            return
        }
        
        //let SharedURL = BaseUrl + username + query
        
        //UserDefaults(suiteName: "group.InstaStats")!.set(SharedURL, forKey: "SharedURL")

        UserDefaults(suiteName: "group.InstaStats")!.set(TestSharedURL, forKey: "TestSharedURL")
        
        WidgetCenter.shared.reloadAllTimelines()
        
        URLSession.shared.dataTask(with: url) {(data,response,error) in
            
            do {
                
                if let d = data {

                    let instadata = try JSONDecoder().decode(InstaData.self, from: d)
                    
                    DispatchQueue.main.async {
                        
                        //print(instadata)
                        self.data = instadata
                        
                        self.NewFollowerCount = instadata.graphql.user.edge_followed_by.count
                        //print(self.NewFollowerCount)
                        UserDefaults.standard.set(self.NewFollowerCount, forKey: "NewFollowerCount")
                        UserDefaults(suiteName: "group.InstaStats")!.set(self.NewFollowerCount, forKey: "SharedFollowerCount")
                        
                        self.FullName = instadata.graphql.user.full_name
                        UserDefaults.standard.set(self.FullName, forKey: "FullName")
                        UserDefaults(suiteName: "group.InstaStats")!.set(self.FullName, forKey: "SharedFullName")
                        
                        UserDefaults.standard.set(self.username, forKey: "username")
                        UserDefaults(suiteName: "group.InstaStats")!.set(self.username, forKey: "Sharedusername")
                        
                        self.ProfilePic = instadata.graphql.user.profile_pic_url_hd
                        UserDefaults.standard.set(self.ProfilePic, forKey: "ProfilePic")
                        UserDefaults(suiteName: "group.InstaStats")!.set(self.ProfilePic, forKey: "SharedProfilePic")
                        
                        UserDefaults.standard.synchronize()
                        
                        WidgetCenter.shared.reloadAllTimelines()
                        
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
    
}

// MARK: - Data Model

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

func YouFuckedUp() {
    let date = Date()
    UserDefaults(suiteName: "group.InstaStats")!.set(date, forKey: "LastRefreshed")
    UserDefaults.standard.synchronize()
    print("You are now fucked up please wait 24 hours to get fucked up again")
}

func StillNotFuckedUp() -> Bool {
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

func SetRefrenceFollowerCount(Refrence_FollowerCount: Int) {
    UserDefaults(suiteName: "group.InstaStats")!.set(Refrence_FollowerCount, forKey: "RefrenceFollowerCount")
    UserDefaults.standard.synchronize()
}

func SetRefrenceDate() {
    let date = Date()
    UserDefaults(suiteName: "group.InstaStats")!.set(date, forKey: "Last_Ref_Followers_Date")
    UserDefaults.standard.synchronize()
}

func GetRefrenceFollowerCount() -> Int {
    return UserDefaults(suiteName: "group.InstaStats")!.integer(forKey: "RefrenceFollowerCount")
}

func GetFollowerCount() -> Int {
    return UserDefaults.standard.integer(forKey: "NewFollowerCount")
}

func GetGains() -> Int {
    let NewFollowerCount = UserDefaults.standard.integer(forKey: "NewFollowerCount")
    if NewFollowerCount - GetRefrenceFollowerCount() >= 0 {
        let Gain = NewFollowerCount - GetRefrenceFollowerCount()
        return Gain
    }
    return 0
}

func GetLoss() -> Int {
    let NewFollowerCount = UserDefaults.standard.integer(forKey: "NewFollowerCount")
    if NewFollowerCount - GetRefrenceFollowerCount() <= 0 {
        let loss = NewFollowerCount - GetRefrenceFollowerCount()
        return loss
    }
    return 0
}

//func UpdateRefrenceFollowerCount(Updated_Followers: Int) {
//    SetRefrenceFollowerCount(Refrence_FollowerCount: Updated_Followers)
//}

func Should_Update_Ref_Followers() -> Bool {
    guard let lastRefFollowersDate = UserDefaults(suiteName: "group.InstaStats")!.object(forKey: "Last_Ref_Followers_Date") as? Date else {
        return true
    }

    if let diff = Calendar.current.dateComponents([.hour], from: lastRefFollowersDate, to: Date()).hour, diff >= 24 {
        print("Ref Date Updated")
        return true
    } else {
        print("Ref Date is not updated")
        return false
    }
}

func UpdateRefrences() {
    if Should_Update_Ref_Followers() {
        SetRefrenceFollowerCount(Refrence_FollowerCount : GetFollowerCount())
        SetRefrenceDate()
    }
}

func CanRefresh() -> Bool {
    guard let WaitForRefresh = UserDefaults(suiteName: "group.InstaStats")!.object(forKey: "WaitForRefresh") as? Date else {
        return true
    }

    if let diff = Calendar.current.dateComponents([.second], from: WaitForRefresh, to: Date()).second, diff >= 5 {
        print("You Can Refresh")
        return true
    } else {
        print("Please wait 30 secs")
        return false
    }
}

func SetRefresh() {
    let date = Date()
    UserDefaults(suiteName: "group.InstaStats")!.set(date, forKey: "WaitForRefresh")
    UserDefaults.standard.synchronize()
    print("Refresh Date Set")
}

func SetLogs() {
    let date = Date()
    let logs = [LogsData(Date: date, Count: 0)]
    UserDefaults(suiteName: "group.InstaStats")!.set(try? PropertyListEncoder().encode(logs), forKey: "Logs")
    UserDefaults.standard.synchronize()
}

func GetLogs() -> [LogsData] {
    let datalogs = UserDefaults(suiteName: "group.InstaStats")!.object(forKey: "Logs")
    return try! PropertyListDecoder().decode(Array<LogsData>.self, from: datalogs as! Data)
}

struct LogsData: Codable {
    var Date: Date
    var Count: Int
}

func AppendLogs() {
    
    let date = Date()
    let NewFollowerCount = UserDefaults.standard.integer(forKey: "NewFollowerCount")
    let DiffCount = NewFollowerCount - GetLogRefrenceFollowerCount()
    
    var logs = GetLogs()
    
    let add: LogsData = LogsData(Date: date, Count: DiffCount)
    
    if DiffCount != 0 {
        
        logs.append(add)
        
        UserDefaults(suiteName: "group.InstaStats")!.set(try? PropertyListEncoder().encode(logs), forKey: "Logs")
    }
    
    UpdateLogRefrences()
    
    UserDefaults.standard.synchronize()
    
}

func SetLogRefrenceFollowerCount(Log_Refrence_FollowerCount: Int) {
    UserDefaults(suiteName: "group.InstaStats")!.set(Log_Refrence_FollowerCount, forKey: "LogRefrenceFollowerCount")
    UserDefaults.standard.synchronize()
}

func GetLogRefrenceFollowerCount() -> Int {
    return UserDefaults(suiteName: "group.InstaStats")!.integer(forKey: "LogRefrenceFollowerCount")
}

func UpdateLogRefrences() {
    SetLogRefrenceFollowerCount(Log_Refrence_FollowerCount : GetFollowerCount())
}

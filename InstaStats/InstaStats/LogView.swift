//
//  LogView.swift
//  InstaStats
//
//  Created by Yaseen Mallick on 15/01/21.
//

import SwiftUI

struct LogView: View {
    var body: some View {
        let logs = GetLogs()
        
        //List(logs,id: \.Date) { logs in
        //    HStack(spacing: 30) {
        //        Text(logs.Count.description)
        //        //Text(logs.Date.description)
        //        Text(formatDate(date: logs.Date))
        //    }
        //}
        
        HStack(spacing: 15){
            
            ForEach(logs,id: \.Date){ logs in
                
                if logs.Count == 0 {
                    
                    // data is loading...
                    
                    //RoundedRectangle(cornerRadius: 5)
                    //    .fill(Color.gray)
                }
                else{
                    
                    // data View...
                    
                    VStack(spacing: 15){
                        
                        Text("\(logs.Count)")
                            .font(.system(size: 10))
                            .fontWeight(.medium)
                        
                        // Graph...
                        
                        GeometryReader{g in
                            
                            VStack{
                                
                                Spacer(minLength: 0)
                                
                                RoundedRectangle(cornerRadius: 5)
                                    .fill(Color(.cyan))
                                // caluclating height...
                                    .frame(height: getHeight(value: CGFloat(logs.Count), height: g.frame(in: .global).height))
                            }
                        }
                        
                        // date...
                        
                        Text(formatDate(date: logs.Date))
                            .font(.caption2)
                    }
                }
            }
        }
        .padding(.horizontal)
        .padding(.bottom,10)
        
    }
}

struct LogView_Previews: PreviewProvider {
    static var previews: some View {
        LogView()
    }
}

func formatDate(date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "dd MMM"
    let dateString = formatter.string(from: date)
    return dateString
}

func getHeight(value : CGFloat,height : CGFloat)->CGFloat{
    
    let max = GetLogs().max { (first, second) -> Bool in
        
        if first.Count > second.Count{return false}
        else{return true}
    }
    
    let percent = value / CGFloat(max!.Count)

    return percent * height/5
}

//
//  TimerView.swift
//  TheRecipe
//
//  Created by Elena Zisina on 7/9/22.
//FIXME: This is unfinished component. 
import SwiftUI
import Combine

struct TimerView: View {
    @Binding var timeElapsed: Double
    var notifyAfter = 0.0
    var onAlarm: () -> Void = { }
    
    @State private var isTicking = false
    @State private var isTickerVisible = false
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        HStack {

            Label("\(abs(notifyAfter - timeElapsed).humanReadableTimeTimerLook)", systemImage: "clock.fill")
                .labelStyle(.titleOnly)
                .foregroundColor(.accentColor)
                
                .font(.subheadline)
                .onReceive(timer) {_ in
                    guard isTicking else {
                        isTickerVisible = false
                        return
                    }
                    timeElapsed += 1
                    if notifyAfter > 0, (notifyAfter - timeElapsed).isZero {
                        onAlarm()
                    }
                    withAnimation(.easeInOut(duration: 1)) {
                        isTickerVisible.toggle()
                    }
                }
                .padding(.horizontal, 3)
                .padding(.bottom, 4)
                .background(alignment: .bottom) {
                    minuteProgress
                }
        }.shadow(radius: 3)
            .onAppear {
                isTicking = true
            }
            .onDisappear {
                isTicking = false
                timeElapsed = 0
            }
    }
    
    private var minuteProgress: some View {
        Rectangle()
            .fill(LinearGradient(colors: [.clear, .accentColor, .white, .accentColor, .clear], startPoint: .leading, endPoint: .trailing))
            .frame(height: 2)
            .opacity(isTickerVisible ? 1.0 : 0.3)
        
    }
}
  /*
extension TimelineSchedule where Self == PeriodicTimelineSchedule {
    static var everyOneSeconds: PeriodicTimelineSchedule {
        get { .init(from: .now, by: 1.0) }
    }
    
}
extension Date {
    func get(_ component : Calendar.Component) -> Int {
        Calendar.current.component(component, from: self)
    }
}
     */
struct TimerView_Previews: PreviewProvider {
    @State private static var timeElapsed = 0.0
    static var previews: some View {
        TimerView(timeElapsed: $timeElapsed, notifyAfter: 320 )
    }
}

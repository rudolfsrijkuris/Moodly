//
//  Home.swift
//  BreatheAnimation
//
//  Created by Rudolfs Rijkuris on 17/07/2023.
//

import SwiftUI
import AVFoundation
import RevenueCat
import Billboard

var player: AVAudioPlayer!

struct Home: View {
    
    // MARK: View Properties
    @State var currentType: BreatheType = sampleTypes[0]
    @Namespace var animation
    
    // MARK: Animation Properties
    @State var showBreatheView: Bool = false
    @State var startAnimation: Bool = false
    
    // MARK: Timer Properties
    @State var timerCount: CGFloat = 0
    @State var breatheAction: String = "Breathe In"
    @State var count: Int = 0
    
    // MARK: Settings View properties
    @State private var showSettings = false
    
    // MARK: Paywall View properties
    @State private var showPaywall = false
    @State private var isPremium = false
    
    // MARK: Streak View properties
    @State private var showStreak = false
    
    // MARK: Ad properties
    @State private var advert: BillboardAd? = nil
    @State private var showRandomAdvert = false
    @State private var showAd = false
    @State private var allAds : [BillboardAd] = []
    let config = BillboardConfiguration(advertDuration: 5)
    
    // MARK: Quote properties
    @State private var selectedQuote = ""
    
    var body: some View {
        ZStack{
            Background()
            
            Content()
            
            Text(breatheAction)
                .font(.largeTitle)
                .foregroundColor(.white)
                .frame(maxHeight: .infinity,alignment: .top)
                .padding(.top,50)
                .opacity(showBreatheView ? 1 : 0)
                .animation(.easeInOut(duration: 1), value: breatheAction)
                .animation(.easeInOut(duration: 1), value: showBreatheView)
        }
        // MARK: Timer
        .onReceive(Timer.publish(every: 0.01, on: .main, in: .common).autoconnect()) { _ in
            if showBreatheView{
                // MARK: Extra Time For 0.1 Delay
                if timerCount >= 3.2{
                    timerCount = 0
                    breatheAction = (breatheAction == "Breathe Out" ? "Breathe In" : "Breathe Out")
                    withAnimation(.easeInOut(duration: 3).delay(0.1)){
                        startAnimation.toggle()
                    }
                    // MARK: Haptic Feedback
                    UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                }else{
                    timerCount += 0.01
                }
                
                count = 3 - Int(timerCount)
            }else{
                // MARK: Resetting
                timerCount = 0
            }
        }
    }
    
    // MARK: Main Content
    @ViewBuilder
    func Content()->some View{
        VStack{
            HStack{
                Button {
                    
                } label: {
                    Image(systemName: "crown")
                        .font(.title2)
                        .foregroundColor(.white)
                        .frame(width: 42, height: 42)
                        .background {
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(.ultraThinMaterial)
                        }
                        .onTapGesture {
                            showPaywall.toggle()
                            
                        }
                }
                
                if isPremium {
                    Button {
                        
                    } label: {
                        Image(systemName: "flame")
                            .font(.title2)
                            .foregroundColor(.white)
                            .frame(width: 42, height: 42)
                            .background {
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .fill(.ultraThinMaterial)
                            }
                            .onTapGesture {
                                showStreak.toggle()
                                
                            }
                    }
                }
                
                Text("Moodly")
                    .font(.largeTitle)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity,alignment: .center)
                
                Button {
                    
                } label: {
                    Image(systemName: "gearshape")
                        .font(.title2)
                        .foregroundColor(.white)
                        .frame(width: 42, height: 42)
                        .background {
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(.ultraThinMaterial)
                        }
                        .onTapGesture {
                            showSettings.toggle()
                        }
                }
            }
            .padding()
            .opacity(showBreatheView ? 0 : 1)
            
            HStack {
                if !isPremium {
                    if let advert = allAds.randomElement() {
                        Section {
                            BillboardBannerView(advert: advert)
                                .listRowBackground(Color.clear)
                                .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                                .padding()
                        }
                    }
                } else {
                    HStack {
                        VStack(alignment: .leading) {
                            HStack {
                                Text("Daily Tip")
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            }
                            Text(selectedQuote)
                                .font(.body)
                                .foregroundColor(.white)
                                .padding(.bottom, UIScreen.main.bounds.height * 0.005)
                                .padding(.top, UIScreen.main.bounds.height * 0.001)
                                .onAppear {
                                    let storedDate = UserDefaults.standard.object(forKey: "lastChanged") as? Date
                                    let storedQuote = UserDefaults.standard.string(forKey: "selectedQuote")
                                    
                                    if let storedDate = storedDate, let storedQuote = storedQuote, Calendar.current.isDateInToday(storedDate) {
                                        selectedQuote = storedQuote
                                    } else {
                                        selectedQuote = DailyTips.quotes.randomElement() ?? ""
                                        UserDefaults.standard.set(Date(), forKey: "lastChanged")
                                        UserDefaults.standard.set(selectedQuote, forKey: "selectedQuote")
                                    }
                                }
                        }
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                    
                    .padding(UIScreen.main.bounds.height * 0.025)
                    .background(currentType.color)
                    .cornerRadius(UIScreen.main.bounds.height * 0.025)
                    .padding()
                }
            }
            .opacity(showBreatheView ? 0 : 1)
            .onAppear {
                updatePremiumStatus()
            }
            
            GeometryReader{proxy in
                let size = proxy.size
                
                VStack{
                    
                    
                    BreatheView(size: size)
                    
                    // MARK: View Properties
                    Text("Breathe to reduce")
                        .font(.title3)
                        .foregroundColor(.white)
                        .opacity(showBreatheView ? 0 : 1)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12){
                            ForEach(sampleTypes){type in
                                Text(type.title)
                                    .foregroundColor(currentType.id == type.id ? .black : .white)
                                    .padding(.vertical,10)
                                    .padding(.horizontal,15)
                                    .background {
                                        // MARK: Matched Geometry Effect
                                        ZStack{
                                            if currentType.id == type.id{
                                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                                    .fill(.white)
                                                    .matchedGeometryEffect(id: "TAB", in: animation)
                                            }else{
                                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                                    .stroke(.white.opacity(0.5))
                                            }
                                        }
                                    }
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        withAnimation(.easeInOut){
                                            currentType = type
                                        }
                                    }
                            }
                        }
                        .padding()
                        .padding(.leading,25)
                    }
                    .opacity(showBreatheView ? 0 : 1)
                    
                    Button(action: {
                        if showBreatheView {
                            startBreathing()
                            stopSound()
                            showAd = true
                            showBreatheView = false
                        } else {
                            startBreathing()
                            playSound()
                            showBreatheView = true
                        }
                        
                    }) {
                        Text(showBreatheView ? "Finish Breathe" : "START")
                            .fontWeight(.semibold)
                            .foregroundColor(showBreatheView ? .white.opacity(0.75) : .black)
                            .padding(.vertical,15)
                            .frame(maxWidth: .infinity)
                            .background {
                                if showBreatheView {
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .stroke(.white.opacity(0.5))
                                } else {
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .fill(currentType.color.gradient)
                                }
                            }
                    }
                    .padding()
//                    .fullScreenCover(isPresented: $showAd) {
//                        if let advert = advert {
//                            BillboardView(advert: advert, paywall: { Text("Paywall") })
//                        } else {
//                            Text("No ad available")
//                        }
//                    }

                }
                .frame(width: size.width, height: size.height, alignment: .bottom)
            }
            .sheet(isPresented: $showSettings, content: {
                Settings(isPresented: $showSettings)
            })
            .sheet(isPresented: $showPaywall, content: {
                Paywall(isPresented: $showPaywall)
            })
            .sheet(isPresented: $showStreak, content: {
                Streak(isPresented: $showStreak)
            })
        }
        .frame(maxHeight: .infinity,alignment: .top)
        .refreshable {
            Task {
                if let allAds = try? await BillboardViewModel.fetchAllAds(from: config.adsJSONURL!) {
                    self.allAds = allAds
                }
            }
        }
        .task {
            
            if let allAds = try? await BillboardViewModel.fetchAllAds(from: config.adsJSONURL!) {
                self.allAds = allAds
            }
        }
        
    }
    
    // MARK: Check if Premium subscription is active
    func updatePremiumStatus() {
        Purchases.shared.getCustomerInfo { (customerInfo, error) in
            if let error = error {
                print("[MOODLY DEBUG] Error fetching customer info: \(error)")
            } else if customerInfo?.entitlements["Premium"]?.isActive == true {
                print("[MOODLY DEBUG] Premium subscription is active")
                isPremium = true
            } else {
                print("[MOODLY DEBUG] Premium subscription is NOT active")
                isPremium = false
            }
        }
    }
    
    // MARK: Breathe Animated Circles
    @ViewBuilder
    func BreatheView(size: CGSize)->some View{
        // MARK: We're Going to Use 8 Circles
        // It's Your Wish
        // 360/8 = 45deg For Each Circle
        ZStack{
            ForEach(1...8,id: \.self){index in
                Circle()
                    .fill(currentType.color.gradient.opacity(0.5))
                    .frame(width: 150, height: 150)
                    // 150 / 2 -> 75
                    .offset(x: startAnimation ? 0 : 75)
                    .rotationEffect(.init(degrees: Double(index) * 45))
                    .rotationEffect(.init(degrees: startAnimation ? -45 : 0))
            }
        }
        .scaleEffect(startAnimation ? 0.8 : 1)
        .overlay(content: {
            Text("\(count == 0 ? 1 : count)")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .animation(.easeInOut, value: count)
                .opacity(showBreatheView ? 1 : 0)
        })
        .frame(height: (size.width - 40))
    }
    
    // MARK: Background Image With Gradient Overlays
    @ViewBuilder
    func Background()->some View{
        GeometryReader{proxy in
            let size = proxy.size
            Image("BG")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .offset(y: -50)
                .frame(width: size.width, height: size.height)
                .clipped()
                // MARK: Blurring While Breathing
                .blur(radius: startAnimation ? 4 : 0, opaque: true)
                .overlay {
                    ZStack{
                        Rectangle()
                            .fill(.linearGradient(colors: [
                                currentType.color.opacity(0.9),
                                .clear,
                                .clear
                            ], startPoint: .top, endPoint: .bottom))
                            .frame(height: size.height / 1.5)
                            .frame(maxHeight: .infinity,alignment: .top)
                        
                        Rectangle()
                            .fill(.linearGradient(colors: [
                                .clear,
                                .black,
                                .black,
                                .black,
                                .black
                            ], startPoint: .top, endPoint: .bottom))
                            .frame(height: size.height / 1.35)
                            .frame(maxHeight: .infinity,alignment: .bottom)
                    }
                }
        }
        .ignoresSafeArea()
    }
    
    // MARK: Breathing Action
    func startBreathing(){
        withAnimation(.interactiveSpring(response: 0.6, dampingFraction: 0.7, blendDuration: 0.7)){
            showBreatheView.toggle()
        }
        
        if showBreatheView{
            // MARK: Breathe View Animation
            // Since We Have Max 3 Secs Of Breathe
            withAnimation(.easeInOut(duration: 3).delay(0.05)){
                startAnimation = true
            }
        }else{
            withAnimation(.easeInOut(duration: 1.5)){
                startAnimation = false
            }
        }
    }
    
    // MARK: Play music in background when doing breathing exercise
    func playSound() {
        let url = Bundle.main.url(forResource: "calm-music", withExtension: "mp3")
        
        guard url != nil else {
            return
        }
        
        do {
            player = try AVAudioPlayer(contentsOf: url!)
            player?.play()
        } catch {
            print("error")
        }
    }
    
    // MARK: Stop music in background when exiting breathing exercise
    func stopSound() {
        let url = Bundle.main.url(forResource: "calm-music", withExtension: "mp3")
        
        guard url != nil else {
            return
        }
        
        do {
            player = try AVAudioPlayer(contentsOf: url!)
            player?.stop()
        } catch {
            print("error")
        }
    }
}

struct Streak: View {
    @Binding var isPresented: Bool
    @State private var streak: Int = UserDefaults.standard.integer(forKey: "streak")
    @State private var lastOpened: Double = UserDefaults.standard.double(forKey: "lastOpened")

    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    Button {
                    } label: {
                        Image(systemName: "x.circle")
                            .font(.title)
                            .foregroundColor(.white.opacity(0.5))
                            .frame(width: 42, height: 42)
                            .frame(maxWidth: .infinity,alignment: .trailing)
                            .onTapGesture {
                                isPresented = false
                            }
                    }
                }
                .padding()
                
                ZStack {
                    Color("SettingsBackground")
                        .ignoresSafeArea()
                    
                    VStack {
                        ZStack {
//                            Circle()
//                                .stroke(.white.opacity(0.1), lineWidth: 50)
//                            Circle()
//                                .trim(from: 0, to: 0.34)
//                                .stroke(.mint, style: StrokeStyle(
//                                    lineWidth: 50,
//                                    lineCap: .round,
//                                    lineJoin: .round
//                                ))
//                                .rotationEffect(.degrees(-90))
                            
                            VStack {
                                Spacer()
                                Text("You've reached")
                                    .font(.title)
                                Text(String(streak) + " day streak")
                                    .fontWeight(.bold)
                                    .font(.system(size: UIScreen.main.bounds.height * 0.06))
                                    .padding(.bottom, UIScreen.main.bounds.height * 0.05)
                                Image("fire")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .padding()
                                Spacer()
                            }
                            .foregroundStyle(.white)
                            .fontDesign(.rounded)
                        }
                        .padding(.horizontal, UIScreen.main.bounds.height * 0.06)
                    }
                }
            }
            .background(Color("SettingsBackground"))
            .onAppear {
                updateStreak()
            }
        }
    }

    func updateStreak() {
        let today = Calendar.current.startOfDay(for: Date())
        let lastOpenedDate = Date(timeIntervalSince1970: lastOpened)
        let lastOpenedStartOfDay = Calendar.current.startOfDay(for: lastOpenedDate)

        if Calendar.current.isDate(lastOpenedStartOfDay, inSameDayAs:today) {
            return
        }

        if let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today),
           Calendar.current.isDate(lastOpenedStartOfDay, inSameDayAs:yesterday) {
            // User opened the app yesterday, increment the streak
            self.streak += 1
        } else {
            // User didn't open the app yesterday, reset the streak
            self.streak = 1
        }

        // Save the date and streak
        self.lastOpened = today.timeIntervalSince1970
        UserDefaults.standard.set(self.lastOpened, forKey: "lastOpened")
        UserDefaults.standard.set(self.streak, forKey: "streak")
    }
}





struct Settings: View {
    @Binding var isPresented: Bool
    @State private var adverts: BillboardAd? = nil
    @State private var allAds : [BillboardAd] = []
    let config = BillboardConfiguration(advertDuration: 5)
    @State private var isPremium = false
    @State private var showingRestoreAlert = false
    @State private var alertMessage = ""
    @State private var alertTitle = ""
    
    var body: some View {
        
        NavigationStack {
            VStack {
                HStack{
                    Text("Settings")
                        .font(.largeTitle)
                        .fontDesign(.rounded)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity,alignment: .leading)
                    
                    Button {
                        
                    } label: {
                        Image(systemName: "x.circle")
                            .font(.title)
                            .foregroundColor(.gray.opacity(0.5))
                            .frame(width: 42, height: 42)
                            .onTapGesture {
                                isPresented = false
                            }
                    }
                }
                .padding()
                
                VStack {
                    
                    List {
                        Section(content: {
                            let faqurl = URL(string: "https://nimble-helicopter-234.notion.site/Moody-FAQ-a47886266fe7496da0bcfb25e420d61b?pvs=4")!
                            let tosurl = URL(string: "https://nimble-helicopter-234.notion.site/Moody-Terms-of-Service-ddeabfddebfd4cac8085568082f13aa4?pvs=4")!
                            let ppurl = URL(string: "https://nimble-helicopter-234.notion.site/Moody-Privacy-Policy-dfb652b2a24a4aa08937765d8ae585a2?pvs=4")!
                            
                            HStack {
                                Text("🤷🏼‍♂️ FAQ")
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                UIApplication.shared.open(faqurl)
                            }
                            
                            HStack {
                                Text("⚡️ Terms of Use")
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                UIApplication.shared.open(tosurl)
                            }
                            
                            HStack {
                                Text("👤 Privacy Policy")
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                UIApplication.shared.open(ppurl)
                            }
                        }, header: {
                            Text("Moodly")
                        })
                        
                        Section(content: {
                            let igurl = URL(string: "https://www.instagram.com/moodly_app/")!
                            let tturl = URL(string: "https://www.tiktok.com/@moodly_app")!
                            
                            HStack {
                                Text("🎶 Follow Moodly on TikTok")
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                UIApplication.shared.open(tturl)
                            }
                            
                            HStack {
                                Text("📸 Follow Moodly on Instagram")
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                UIApplication.shared.open(igurl)
                            }
                        }, header: {
                            Text("Community")
                        })
                        
                        Section(content: {
                            let cuurl = URL(string: "mailto:rudolfs@rijkuris.com")!
                            
                            HStack {
                                Text("✉️ Contact Us")
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                UIApplication.shared.open(cuurl)
                            }
                        }, header: {
                            Text("About")
                        })
                        
                        if !isPremium {
                            
                            if let advert = allAds.randomElement() {
                                Section {
                                    BillboardBannerView(advert: advert)
                                        .listRowBackground(Color.clear)
                                        .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                                }
                            }
                        }
                    }
                    
                    
                    Text("Moodly 2.0.0")
                        .foregroundColor(.gray.opacity(0.8))
                    Text("Made with ♥️ in Latvia 🇱🇻")
                        .foregroundColor(.gray.opacity(0.8))
                    Button("Restore Purchases") {
                        Purchases.shared.restorePurchases { customerInfo, error in
                            if let error = error {
                                alertMessage = "Error fetching user info: \(error)"
                            } else if customerInfo?.entitlements["Premium"]?.isActive == true {
                                alertTitle = "Subscription restored"
                                alertMessage = "Your subscription is restored"
                                showingRestoreAlert = true
                            } else {
                                alertTitle = "No subscription found"
                                alertMessage = "Your subscription could not be restored"
                                showingRestoreAlert = false
                            }
                        }
                        
                    }
                    .foregroundColor(.mint)
                    .background(.clear)
                    .padding(.top, UIScreen.main.bounds.height * 0.01)
                    .alert(isPresented: $showingRestoreAlert) {
                        Alert(title: Text(alertTitle), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                    }
                }
                .refreshable {
                    Task {
                        if let allAds = try? await BillboardViewModel.fetchAllAds(from: config.adsJSONURL!) {
                            self.allAds = allAds
                        }
                    }
                }
                .task {
                    
                    if let allAds = try? await BillboardViewModel.fetchAllAds(from: config.adsJSONURL!) {
                        self.allAds = allAds
                    }
                }
                
            }
            //.padding(.bottom, UIScreen.main.bounds.height * 0.81)
            .background(Color("SettingsBackground"))
            .onAppear {
                updatePremiumStatus()
            }
        }
    }
    
    func updatePremiumStatus() {
        Purchases.shared.getCustomerInfo { (customerInfo, error) in
            if let error = error {
                print("[MOODLY DEBUG] Error fetching customer info: \(error)")
            } else if customerInfo?.entitlements["Premium"]?.isActive == true {
                print("[MOODLY DEBUG] Premium subscription is active")
                isPremium = true
            } else {
                print("[MOODLY DEBUG] Premium subscription is NOT active")
                isPremium = false
            }
        }
    }
}

struct Paywall: View {
    @Binding var isPresented: Bool
    @State var currentOffering: Offering?
    @State private var isPremium = false
    
    var body: some View {
        VStack {
            HStack{
                
                Button {
                    
                } label: {
                    Image(systemName: "x.circle")
                        .font(.title)
                        .foregroundColor(.gray.opacity(0.5))
                        .frame(width: 42, height: 42)
                        .frame(maxWidth: .infinity,alignment: .trailing)
                        .onTapGesture {
                            isPresented = false
                        }
                }
            }
            .padding()
            
            ScrollView {
                VStack {
                    HStack {
                        Image("launch-screen")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: UIScreen.main.bounds.height * 0.2, maxHeight: UIScreen.main.bounds.height * 0.2)
                    }
                    
                    HStack {
                        Text("Premium Version")
                            .font(.largeTitle)
                            .bold()
                            .foregroundColor(Color("Gray").opacity(0.9))
                    }
                    
                    HStack {
                        Text("Unlock All Features")
                            .font(.headline)
                            .bold()
                            .foregroundColor(Color("Gray").opacity(0.9))
                        
                    }
                    
                    // MARK: Premium features
                    if !isPremium {
                        HStack {
                            Image(systemName: "checkmark.seal")
                                .font(.title3)
                                .foregroundColor(Color("Gray").opacity(0.7))
                            Text("Daily Tips")
                                .font(.title3)
                                .foregroundColor(Color("Gray").opacity(0.7))
                        }
                        .frame(maxWidth: .infinity,alignment: .leading)
                        .padding(.leading, UIScreen.main.bounds.height * 0.08)
                        .padding(.top, UIScreen.main.bounds.height * 0.03)
                        
                        HStack {
                            Image(systemName: "checkmark.seal")
                                .font(.title3)
                                .foregroundColor(Color("Gray").opacity(0.7))
                            Text("Emotion Management Insights")
                                .font(.title3)
                                .foregroundColor(Color("Gray").opacity(0.7))
                        }
                        .frame(maxWidth: .infinity,alignment: .leading)
                        .padding(.leading, UIScreen.main.bounds.height * 0.08)
                        .padding(.top, UIScreen.main.bounds.height * 0.01)
                        
                        HStack {
                            Image(systemName: "checkmark.seal")
                                .font(.title3)
                                .foregroundColor(Color("Gray").opacity(0.7))
                            Text("No Ads")
                                .font(.title3)
                                .foregroundColor(Color("Gray").opacity(0.7))
                        }
                        .frame(maxWidth: .infinity,alignment: .leading)
                        .padding(.leading, UIScreen.main.bounds.height * 0.08)
                        .padding(.top, UIScreen.main.bounds.height * 0.01)
                        
                        // MARK: Payment button
                        HStack {
                            if currentOffering != nil {
                                ForEach(currentOffering!.availablePackages) { pkg in
                                    Button {
                                        // BUY
                                        Purchases.shared.purchase(package: pkg) { (transaction, customerInfo, error, userCancelled) in
                                            
                                            if customerInfo?.entitlements.all["Premium"]?.isActive == true {
                                                // Unlock that great "pro" content
                                                
                                                isPremium = true
                                            }
                                        }
                                    } label: {
                                        Text("\(pkg.storeProduct.subscriptionPeriod!.periodTitle) \(pkg.storeProduct.localizedPriceString)")
                                            .fontWeight(.semibold)
                                            .foregroundColor(.white)
                                            .padding(.vertical,15)
                                            .frame(maxWidth: .infinity)
                                            .background {
                                                RoundedRectangle(cornerRadius: 180, style: .continuous)
                                                    .fill(Color("Green").gradient)
                                            }
                                    }
                                    .padding()
                                }
                            }
                        }
                        
                        
                        
                        // MARK: Privacy Policy & Terms of Services
                        let tosurl = URL(string: "https://nimble-helicopter-234.notion.site/Moody-Terms-of-Service-ddeabfddebfd4cac8085568082f13aa4?pvs=4")!
                        let ppurl = URL(string: "https://nimble-helicopter-234.notion.site/Moody-Privacy-Policy-dfb652b2a24a4aa08937765d8ae585a2?pvs=4")!
                        
                        HStack {
                            Text("Privacy Policy")
                                .fontWeight(.semibold)
                                .font(.footnote)
                                .foregroundColor(Color("Gray").opacity(0.8))
                                .onTapGesture {
                                    UIApplication.shared.open(ppurl)
                                }
                            
                            Text("Terms of Services")
                                .fontWeight(.semibold)
                                .font(.footnote)
                                .foregroundColor(Color("Gray").opacity(0.8))
                                .onTapGesture {
                                    UIApplication.shared.open(tosurl)
                                }
                        }
                        .padding(.top, UIScreen.main.bounds.height * 0.01)
                        
                        // MARK: Payment Disclaimer
                        HStack {
                            Text("Payment will be charged to your iTunes account at confirmation of purchase. Subscriptions will automatically renew unless auto-renew is turned off at least 24 hours before the end of current period. Your account will be charged according to your plan for renewal within 24 hours prior to the end of the current period. You can manage or turn of auto-renew in your Apple ID account settings at any time after purchase.")
                                .font(.caption)
                                .foregroundColor(Color("Gray").opacity(0.4))
                                .frame(maxWidth: .infinity, alignment: .center)
                                .multilineTextAlignment(.center)
                        }
                        .padding()
                        .padding(.top, UIScreen.main.bounds.height * 0.01)
                    } else {
                        VStack {
                            HStack {
                                VStack(alignment: .leading) {
                                    HStack {
                                        Text("Subscription")
                                            .font(.title3)
                                            .fontWeight(.semibold)
                                            .foregroundColor(.white)
                                        Spacer()
                                        Text("Active")
                                            .font(.title3)
                                            .fontWeight(.bold)
                                            .foregroundColor(.white)
                                    }
                                    
                                }
                                Spacer()
                            }
                            .frame(maxWidth: .infinity)
                            .padding(UIScreen.main.bounds.height * 0.025)
                            .background(Color("Green").gradient)
                            .cornerRadius(UIScreen.main.bounds.height * 0.025)
                            .padding()
                        }
                    }
                }
                .onAppear {
                    Purchases.shared.getOfferings { offerings, error in
                        if let offer = offerings?.current, error == nil {
                            currentOffering = offer
                        }
                    }
                }
            }
        }
        .onAppear {
            updatePremiumStatus()
        }
    }
    
    func updatePremiumStatus() {
        Purchases.shared.getCustomerInfo { (customerInfo, error) in
            if let error = error {
                print("[MOODLY DEBUG] Error fetching customer info: \(error)")
            } else if customerInfo?.entitlements["Premium"]?.isActive == true {
                print("[MOODLY DEBUG] Premium subscription is active")
                isPremium = true
            } else {
                print("[MOODLY DEBUG] Premium subscription is NOT active")
                isPremium = false
            }
        }
    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        Home()
    }
}

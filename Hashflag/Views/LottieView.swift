//
//  LottieView.swift
//  Hashflag
//
//  Created by Eric Lewis on 9/10/20.
//

import SwiftUI
import Lottie

struct LottieView: UIViewRepresentable {
    var url: URL
    var loopMode: LottieLoopMode = .playOnce
    var animationView = AnimationView()
    
    func makeUIView(context: UIViewRepresentableContext<LottieView>) -> UIView {
        let view = UIView()
        
        Lottie.Animation.loadedFrom(url: url, closure: { self.animationView.animation = $0 }, animationCache: nil)
        animationView.contentMode = .scaleAspectFill
        animationView.loopMode = .loop
        
        animationView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(animationView)
        
        NSLayoutConstraint.activate([
            animationView.widthAnchor.constraint(equalTo: view.widthAnchor),
            animationView.heightAnchor.constraint(equalTo: view.heightAnchor)
        ])
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<LottieView>) {
        animationView.play()
    }
}

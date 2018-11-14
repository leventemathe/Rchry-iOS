# Rchry-iOS
An iOS app that helps you track your archery performance.
Login with Facebook then create targets. Tap a target to see your stats or start a new shooting session.  
You can also track guest users to compare your scores later. Scoring is easy: just tap the score you and your friends shot.


<p float="left" align="center">
  <img src="/doc/img/1_login.png" width="30%"/>
  <img src="/doc/img/2_new_target.png" width="30%"> 
  <img src="/doc/img/3_targets.png" width="30%"/>
</p>

<p float="left" align="center">
  <img src="/doc/img/4_target.png" width="30%"/>
  <img src="/doc/img/5_new_session.png" width="30%"/> 
  <img src="/doc/img/6_session.png" width="30%"/>
</p>

# Technology
The app is written in Swift with MVVM and RxSwift (in fact, I used this app to learn RxSwift and RxCocoa, so you can see different (better and worse) ways of using them).
The data (targets, sessions, guests) is persisted to Firebase.

//
//  ContentView.swift
//  test
//
//  Created by Shengkai Sun on 5/07/24.
//

import SwiftUI
import Peppermint


struct ContentView: View {
//  登录状态
    @State var isLoggedIn: Bool = false

    var body: some View {
        if !isLoggedIn {
            LoginView(isLoggedIn: $isLoggedIn)
        } else {
            LoggedinView()
        }
    }
}

struct PwdFieldView: View {
    @Binding var showValue: Bool
    @Binding var value: String
    @Binding var isValid: Bool
    
    let placeholder: String
    
    let invalidColor: Color
    let fieldBgColor: Color
    
    let cornerRad: CGFloat
    
    var body: some View {
        Group {
            if showValue {
                HStack {
                    TextField(placeholder, text: $value)
                        .autocapitalization(.none)
                        .autocorrectionDisabled(true)
                    Image(systemName: "eye")
                        .onTapGesture {
                            showValue.toggle()
                        }
                }
            } else {
                HStack {
                    SecureField(placeholder, text: $value)
                    Image(systemName: "eye.slash")
                        .onTapGesture {
                            showValue.toggle()
                        }
                }
            }
        }
        .padding()
        .overlay(
            RoundedRectangle(cornerRadius: cornerRad)
                .stroke(isValid ? Color.gray : invalidColor)
        )
        .background(RoundedRectangle(cornerRadius: cornerRad).fill(fieldBgColor))
    }
}

struct ButtonStyle: ViewModifier {
    var isEnabled: Bool
    let fieldBgColor: Color
    let activeColor = Color.orange
    let inactiveColor = Color.gray

    func body(content: Content) -> some View {
        content
            .bold()
            .font(.title3)
            .frame(width: 340, height: 50)
            .background(isEnabled ? activeColor : fieldBgColor)
            .foregroundColor(isEnabled ? Color.white : inactiveColor)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(isEnabled ? activeColor : inactiveColor, lineWidth: 2)
            )
            .disabled(!isEnabled)
    }
}

extension View {
    func buttonStyle(isEnabled: Bool, fieldBgColor: Color) -> some View {
        self.modifier(ButtonStyle(isEnabled: isEnabled, fieldBgColor: fieldBgColor))
    }
}

struct LoginView: View {
//  登录状态
    @Binding var isLoggedIn: Bool

//  用户输入
    @State private var userEmail: String = ""
    @State private var pwd: String = ""
    @State private var confirmPwd: String = ""
    
//  隐藏/显示密码
    @State private var showPwd: Bool = false
    @State private var showConfirmPwd: Bool = false
    
//  输入有效性检查
    @State private var emailValid: Bool = true
    @State private var pwdValid: Bool = true
    @State private var confirmPwsValid: Bool = true
    
//  登录无效提示
    @State private var showToast = false
    @State private var toastMsg = "请检查邮箱和密码是否正确"
    
//  校验邮箱，密码
    private let emailConstraint = EmailPredicate()
    private let pwdConstraint = RegexPredicate(expression: "^(?=.*[A-Za-z])(?=.*\\d)[A-Za-z\\d]{8,}$")

//  自定义颜色
    private let invalidColor = Color(red: 190/255, green: 83/255, blue: 65/255)
    private let fieldBgColor = Color(red: 251/255, green: 252/255, blue: 254/255)

//  默认值
    private let cornerRad: CGFloat = 15.0
    private let space = 30.0

//    private static func validteConfirmPwd(pwd: String, confirmPwd: String) -> Bool {
//        return pwd == confirmPwd
//    }

    var body: some View {
        GeometryReader { _ in
            VStack {
                Text("登录")
                    .bold()
                    .font(.title2)
//              邮箱
                VStack(alignment: .leading) {
                    Group {
                        Text("邮箱")
                            .font(.title3)
                        
                        TextField("请输入您的邮箱", text: $userEmail)
                            .padding()
                            .overlay(
                                RoundedRectangle(cornerRadius: cornerRad)
                                    .stroke(emailValid ? Color.gray : invalidColor)
                            )
                            .autocapitalization(.none)
                            .onChange(of: userEmail) { oldValue, newValue in
                                emailValid = emailConstraint.evaluate(with: userEmail)
                            }
                            .background(RoundedRectangle(cornerRadius: cornerRad).fill(fieldBgColor))
//                      邮箱格式错误提示信息
                        if (!emailValid) {
                            Text("请输入正确的邮箱格式")
                                .font(.footnote)
                                .foregroundStyle(invalidColor)
                        }
                    }
                    
                    Spacer()
                        .frame(height: space)
                    
//                  密码
                    Group {
                        Text("密码")
                            .font(.title3)
                        
                        PwdFieldView(showValue: $showPwd, value: $pwd, isValid: $pwdValid, placeholder: "请输入您的密码", invalidColor: invalidColor, fieldBgColor: fieldBgColor, cornerRad: cornerRad)
                        .onChange(of: pwd, { oldValue, newValue in
                            pwdValid = pwdConstraint.evaluate(with: newValue)
                            confirmPwsValid = newValue == confirmPwd
                        })
//                      密码格式提示信息
                        if pwdValid {
                            Text("密码不少于8位，必须包含字母和数字！")
                                .font(.footnote)
                        } else {
                            Text("密码必须不少于8位，包含字母和数字！")
                                .font(.footnote)
                                .foregroundStyle(invalidColor)
                        }
                    }
                    
                    Spacer()
                        .frame(height: space)
                    
//                  确认密码
                    Group {
                        Text("确认密码")
                            .font(.title3)
                        PwdFieldView(showValue: $showConfirmPwd, value: $confirmPwd, isValid: $confirmPwsValid, placeholder: "请确认您的密码", invalidColor: invalidColor, fieldBgColor: fieldBgColor, cornerRad: cornerRad)
                        .onChange(of: confirmPwd, { oldValue, newValue in
                            confirmPwsValid = pwd == newValue
                        })
                        
//                      密码不一致
                        if (!confirmPwsValid) {
                            Text("您输入的密码不一致！")
                                .font(.footnote)
                                .foregroundStyle(invalidColor)
                        }
                    }
                }
                .padding()
                
                Spacer()
                
                Button("登录") {
                    if (emailValid && pwdValid && confirmPwsValid) {
//                      登录成功
                        isLoggedIn.toggle()
                    } else {
//                      提示输入错误
                        showToast.toggle()
                    }
                }
                .buttonStyle(isEnabled: !(userEmail.isEmpty || pwd.isEmpty || confirmPwd.isEmpty), fieldBgColor: fieldBgColor)
                .padding()
            }
            .toast(isPresented: self.$showToast) {
                Text(toastMsg)
                    .foregroundStyle(.white)
            }
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
}

struct LoggedinView: View {
    var body: some View {
        Text("登录成功！")
            .font(.largeTitle)
            .offset(y: -150.0)
    }
}

struct Toast<Presenting, Content>: View where Presenting: View, Content: View {
    @Binding var isPresented: Bool
    let presenter: () -> Presenting
    let content: () -> Content
    let delay: TimeInterval = 2

    var body: some View {
        if self.isPresented {
            DispatchQueue.main.asyncAfter(deadline: .now() + self.delay) {
                withAnimation {
                    self.isPresented = false
                }
            }
        }

        return GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                self.presenter()
                ZStack {
                    Capsule()
                        .fill(Color.gray)
                    self.content()
                } //ZStack (inner)
                .frame(width: geometry.size.width / 1.25, height: geometry.size.height / 10)
                .opacity(self.isPresented ? 1 : 0)
            } //ZStack (outer)
            .padding(.bottom)
        } //GeometryReader
    } //body
} //Toast

extension View {
    func toast<Content>(isPresented: Binding<Bool>, content: @escaping () -> Content) -> some View where Content: View {
        Toast(
            isPresented: isPresented,
            presenter: { self },
            content: content
        )
    }
}

#Preview {
    ContentView()
}

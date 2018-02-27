//
//  ChangePasswordViewControllerSpec.swift
//  ShopAppTests
//
//  Created by Radyslav Krechet on 2/19/18.
//  Copyright © 2018 RubyGarage. All rights reserved.
//

import Nimble
import Quick
import RxSwift

@testable import ShopApp

class ChangePasswordViewControllerSpec: QuickSpec {
    override func spec() {
        var viewController: ChangePasswordViewController!
        var viewModelMock: ChangePasswordViewModelMock!
        var newPasswordTextFieldView: InputTextFieldView!
        var confirmPasswordTextFieldView: InputTextFieldView!
        var updateButton: BlackButton!
        
        beforeEach {
            viewController = UIStoryboard(name: StoryboardNames.account, bundle: nil).instantiateViewController(withIdentifier: ControllerIdentifiers.changePassword) as! ChangePasswordViewController
            
            let repositoryMock = AuthentificationRepositoryMock()
            let updateCustomerUseCaseMock = UpdateCustomerUseCaseMock(repository: repositoryMock)
            viewModelMock = ChangePasswordViewModelMock(updateCustomerUseCase: updateCustomerUseCaseMock)
            viewController.viewModel = viewModelMock
            
            newPasswordTextFieldView = self.findView(withAccessibilityLabel: "newPassword", in: viewController.view) as! InputTextFieldView
            confirmPasswordTextFieldView = self.findView(withAccessibilityLabel: "confirmPassword", in: viewController.view) as! InputTextFieldView
            updateButton = self.findView(withAccessibilityLabel: "update", in: viewController.view) as! BlackButton
        }
        
        describe("when view loaded") {
            it("should have a correct view model type") {
                expect(viewController.viewModel).to(beAKindOf(ChangePasswordViewModel.self))
            }
            
            it("should have a title with correct text") {
                expect(viewController.title) == "ControllerTitle.SetNewPassword".localizable
            }
            
            it("should have a close button") {
                expect(viewController.navigationItem.rightBarButtonItem?.image) == #imageLiteral(resourceName: "cross")
            }
            
            it("should have text filed views with correct placeholders") {
                expect(newPasswordTextFieldView.placeholder) == "Placeholder.NewPassword".localizable.required.uppercased()
                expect(confirmPasswordTextFieldView.placeholder) == "Placeholder.ConfirmPassword".localizable.required.uppercased()
            }
            
            it("should have an update button with correct title") {
                expect(updateButton.title(for: .normal)) == "Button.Update".localizable.uppercased()
            }
        }
        
        describe("when password texts changed") {
            it("needs to update variables of view model") {
                newPasswordTextFieldView.textField.text = "password"
                newPasswordTextFieldView.textField.sendActions(for: .editingChanged)
                confirmPasswordTextFieldView.textField.text = "password"
                confirmPasswordTextFieldView.textField.sendActions(for: .editingChanged)
                
                expect(viewModelMock.newPasswordText.value) == "password"
                expect(viewModelMock.confirmPasswordText.value) == "password"
            }
            
            context("if it have at least one symbol in each text field view") {
                it("needs to enable update button") {
                    viewModelMock.makeUpdateButtonEnabled()
                    
                    expect(updateButton.isEnabled) == true
                }
            }
            
            context("if it doesn't have symbols in both text variables") {
                it("needs to disable update button") {
                    viewModelMock.makeUpdateButtonDisabled()
                    
                    expect(updateButton.isEnabled) == false
                }
            }
        }

        describe("when update button pressed") {
            it("needs to end editing") {
                newPasswordTextFieldView.textField.sendActions(for: .editingDidBegin)
                updateButton.sendActions(for: .touchUpInside)
                
                expect(viewController.isEditing) == false
            }
            
            context("if it have not valid password texts") {
                it("needs to show error messages about not valid password texts") {
                    viewModelMock.makeNotValidPasswordTexts()
                    updateButton.sendActions(for: .touchUpInside)
                    
                    expect(newPasswordTextFieldView.errorMessage) == "Error.InvalidPassword".localizable
                    expect(confirmPasswordTextFieldView.errorMessage) == "Error.InvalidPassword".localizable
                }
            }
            
            context("if it have not equals password texts") {
                it("needs to show error message about not equals password texts") {
                    viewModelMock.makeNotEqualsPasswordTexts()
                    updateButton.sendActions(for: .touchUpInside)
                    
                    expect(confirmPasswordTextFieldView.errorMessage) == "Error.PasswordsAreNotEquals".localizable
                }
            }
            
            context("if it have valid and equals password texts") {
                it("needs to change password and dismiss view controller") {
                    let disposeBag = DisposeBag()
                    
                    viewModelMock.makeValidAndEqualsPasswordTexts()
                    
                    viewModelMock.updateSuccess.asObservable()
                        .subscribe(onNext: { success in
                            expect(success).toEventually(beTrue())
                        })
                        .disposed(by: disposeBag)
                    
                    updateButton.sendActions(for: .touchUpInside)
                }
            }
        }
    }
}
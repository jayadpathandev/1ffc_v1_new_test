useCase fffcReg06LoginInfo [

   /**
    *  author: Maybelle Johnsy Kanjirapallil
    *  created: 01-Oct-2015
    *
    *  Primary Goal:
    *       1. System displays Registration- Setup login profile (Step3 of registration)
    *       
    *  Alternative Outcomes:
    *       1. User cancels the information and returns to the login page 
    *                     
    *   Major Versions:
    *        1.0 1-Oct-2015 First Version Coded [Maybelle Johnsy Kanjirapallil]
    */
    

    documentation [
        preConditions: [[
            1. A user accesses the application
        ]]
        triggers: [[
            1. Users enters correct information on the Registration - Billing Information page and selects next button
        ]]
        postConditions: [[
            1. Primary -- System displays Registration - Setup Secret Questions
            2. Alternative 1 -- Users selects back link, System take users Registration - Billing Information pages
            3. Alternative 2 -- Users selects cancel button, System take users to the Login page
        ]]
    ]
    startAt initialize
    
	/**************************
	 * DATA ITEMS SECTION
	 **************************/	
	 
    importJava Session(com.sorrisotech.app.utils.Session)

	import regCompleteEnrollment.sAppType
	import regCompleteEnrollment.sLoginAction
	
	import validation.passwordRegex
	import validation.usernameRegex
	import regChecklist.sUserNameFailed
	 		  
    string sPageName = "{Registration - Establish Login Profile (step 6 of 8)}"    
		
	native string sUserName = Session.getUsername()
	native string sFirstName = Session.getFirstName()
	native string sLastName = Session.getLastName()
	native string sAppType = Session.getAppType()
	
    serviceStatus srStatus			
    serviceParam(PwRestrict.Validate) srValidateReq
    serviceResult(PwRestrict.Validate) srValidateResp
    
    structure(message) msgPasswordInvalid  [
        string(title) sTitle = "{Insecure password}"
        string(body) sBody = "{The password appears to be a variation of a common password.  Please choose a password harder to guess.}"
    ]
	
    persistent field fUserName [
        string(label) sLabel = "{* Create user name:}"      
		input (control) pInput(usernameRegex, fUserName.sValidation)
		string(required) sRequired = "{This field is required.}"
		string(validation) sValidation = "{User name can be up to 50 characters in length, contain no spaces, and include solely the following special characters: underscore (_), comma (,), period (.), atsign(@), and hyphen (-).}"
		string(error) sError = "{Another user already has this user name. Please select another.}"
    ]
   	
    persistent field fPassword [
        string(label) sLabel = "{* Create password:}"        
        password input(control) pInput(passwordRegex, fPassword.sValidation)
        string(required) sRequired = "{This field is required.}"        
        string(validation) sValidation = "{Password must be 7-20 characters in length and include at least one uppercase character, one lowercase character, and one numeric digit. No spaces are allowed.}" 
        string(validation) sRestricted = "{The password appears to be a variation of a common password.  Please choose a password harder to guess.}"  
    ]
 
    persistent field fConfirmPassword [
	    string(label) sLabel = "{* Confirm password:}"               
        password input(control) pInput
        string(required) sRequired = "{This field is required.}"                
        string(error) sError = "{Password and Confirm password fields should match.}" 
	]
 	      
 	persistent field fFirstName [
        string(label) sLabel = "{* First name:}" 
        input(control) pInput("^[\\p{L}-_ ]{0,29}$", fFirstName.sValidation)
        string(required) sRequired = "{This field is required.}"        
        string(validation) sValidation = "{User first name must be 1-30 characters in length and include solely the following special characters: underscore (_) and hyphen (-).}" 
    ]
        
    persistent field fLastName [
        string(label) sLabel = "{* Last name:}"        
        input(control) pInput("^[\\p{L}-_ ]{0,29}$", fLastName.sValidation)
        string(required) sRequired = "{This field is required.}"         
        string(validation) sValidation = "{User last name must be 1-30 characters in length and include solely the following special characters: underscore (_) and hyphen (-).}" 
    ]
	
	// -- message strings for display when use case completes.       
    structure(message) msgGenericError [
		string(title) sTitle = "{Something wrong happened}"
		string(body) sBody = "{An error occurred while trying to fulfill your request. Please try again later.}"
	]
	
	/**************************************************************************
     * Main Path.
     **************************************************************************/ 
     
	/**************************************************************************
     * 1. Get user details from the session.
     */ 
	action initialize [
    	fUserName.pInput = sUserName
    	fFirstName.pInput = sFirstName
    	fLastName.pInput = sLastName
 		goto(regLoginInfoScreen)
 	]
 	
    /**************************************************************************
     * 2. System displays the Registration Login Screen.
     */    
    noMenu xsltScreen regLoginInfoScreen("{Registration - Establish Login Profile (step 6 of 8)}") [
    	    	
        form regLoginInfoForm [
	    	class: "st-login"
	            
	        div header [
				class: "row"
				
				h1 headerCol [
					class: "col-md-12"
	            
	                display sPageName
	            ]
			]
			
	        div form [
	        	class: "row"	
	        	      
	    		div formContentCol1 [
					class: "col-sm-4"
				
					div row2 [
						class: "row"
								
						div col2 [
							class: "col-md-12"
						
							display fUserName[
								pInput_attr_st-new-user-name: ""								
								control_attr_tabindex: "1"
								control_attr_autofocus: ""
								sError_ng-show: "regLoginInfoForm['fUserName.pInput'].$invalid && !!regLoginInfoForm['fUserName.pInput'].$error.username && regLoginInfoForm['fUserName.pInput'].$dirty"
								sError_attr_sorriso-error: "new-user-name"
							]		
						]
					]
				
					div row4 [
						class: "row"

						div col4 [
							class: "col-md-12"
						
		                	display fPassword [
		                		control_attr_tabindex: "2"
	                    		control_attr_st-new-password: "regLoginInfoForm['fUserName.pInput'].$viewValue"
	                    		sRestricted_ng-show: "regLoginInfoForm['fPassword.pInput'].$invalid && !!regLoginInfoForm['fPassword.pInput'].$error.stNewPassword && regLoginInfoForm['fPassword.pInput'].$dirty"
	                    		control_attr_st-restricted-password: "#fUserName"
	                    		sRestricted_attr_sorriso-error: "restricted-password"
		                	]
						]
					]
				
					div row5 [
						class: "row"

						div col5 [
							class: "col-md-12"
		                
		                	display fConfirmPassword [
								pInput_attr_st-compare-to: "form.fPassword"
								sError_ng-show: "!regLoginInfoForm.$error.stPattern && !!regLoginInfoForm.$error.stCompareTo"
								sError_attr_sorriso-error: 'same-as'
								pInput_attr_st-same-as: 'fPassword'
								control_attr_tabindex: "3"
                        	]
						]
					]
				]
			
		    	div formContentCol2 [
					class: "col-sm-4"	
				
					div row6 [
						class: "row"
		                
						div col6 [
							class: "col-md-12"
		               
		                	display fFirstName [
		                		control_attr_tabindex: "4"
		                	]
						]
                	]	 
				
					div row7 [
						class: "row"

						div col7 [
							class: "col-md-12"
		                
		                	display fLastName [
								control_attr_tabindex: "5"
		                	]
	                	]
					]
				]
			]
			
			div buttons [
				class: "st-buttons"
				
				div buttonsRow1 [
					class: "row"
					
					div buttonsCol1 [
						
						class: "col-md-12"
						
						navigation loginInfoSubmit(verifyPassword, "{Next}") [
		                    class: "btn btn-primary"
		                    
		                    data :[
		                    	fUserName,
								fPassword,
								fConfirmPassword,
								fFirstName,
								fLastName	
		                    ]
		                    
		                    require: [
								fUserName => fUserName.sRequired,
								fPassword => fPassword.sRequired,
								fConfirmPassword => fConfirmPassword.sRequired,
								fFirstName => fFirstName.sRequired,
								fLastName => fLastName.sRequired
							]
							attr_tabindex: "6"	
						]
		               
		                navigation loginInfoCancel(gotoLogin, "{Cancel}") [
							class: "btn btn-secondary"
							attr_tabindex: "7"
		                ]
		                							
						navigation loginInfoBack(checkAppTypeBack, "{Back}") [
							attr_tabindex: "8"
						]
					]
				]					
			]			
        ]               
    ]      

    action verifyPassword [
		srValidateReq.rFor      = sAppType
		srValidateReq.rUserName = fUserName.pInput
		srValidateReq.rPassword = fPassword.pInput
		
		switch apiCall PwRestrict.Validate(srValidateReq, srValidateResp, srStatus) [
		    case apiSuccess checkVerifyResult
		    default verifyPasswordFailed
		]
				    	
    ]
    
    action checkVerifyResult [
		if srValidateResp.valid == "YES" then 
			checkAppType 
		else 
			verifyPasswordFailed    	
    ]
    
    action verifyPasswordFailed [
    	displayMessage(type:"danger" msg: msgPasswordInvalid)
    	goto(regLoginInfoScreen)
    ]

	/**************************************************************************
	 * 3. Check application type b2b or b2c.
	 */    
    action checkAppType [
    	switch sAppType [        
          case "b2c" determineNextUseCaseB2C
          case "b2b"  determineNextUseCaseB2B                 
          default gotoRegBillingInfo
        ]     
    ]
    
    /**************************************************************************
     * 4. Checks the flag and determines where to go.
     */
	action determineNextUseCaseB2C [
		if sUserNameFailed == "true" then
			gotoRegistrationB2C
		else
			gotoRegSecretQuestion	
	]   
	
	/**************************************************************************
     * 5. System takes to the b2c registration usecase. 
     */     
    action gotoRegistrationB2C [    
    	gotoUc(fffcReg99B2C)
    ]  
    
    /**************************************************************************
     * 6. Checks the flag and determines where to go.
     */
	action determineNextUseCaseB2B [
		if sUserNameFailed == "true" then
			gotoRegistrationB2B
		else
			gotoRegSecretQuestion	
	]   
	
	/**************************************************************************
     * 7. System takes to the b2b registration usecase. 
     */     
    action gotoRegistrationB2B [    
    	gotoUc(registrationB2B)
    ]  
    
	/**************************************************************************
	 * 8. System take users to the registration secret question usecase.
	 */
	action gotoRegSecretQuestion [	
		gotoUc(fffcReg07SecretQuestion)
	]    
 
 	/**************************************************************************
     * 9. User selects Cancel button, System takes user to the login page.
     */    
    action gotoLogin [    
    	gotoModule(LOGIN)
    ]
    
    /**************************************************************************
	 * 10. Check application type b2b or b2c.
	 */    
    action checkAppTypeBack [
    	switch sAppType [        
          case "b2c" gotoRegBillingInfo
          case "b2b"  checkB2BLoginAction                 
          default genericErrorMsg
        ]     
    ]
    
    /**************************************************************************
	 * 11. Check if it is new registration or complete registration.
	 */    
 	action checkB2BLoginAction [
 		switch sLoginAction [        
          case "signup" gotoRegBillingInfo
          case "login"  gotoTermsAndConditions                 
          default genericErrorMsg
        ]  
 	]
 	     
 	/**************************************************************************
  	 * 12. User selects back link and the appType is not b2b.
     */
    action gotoRegBillingInfo [
    	gotoUc(regBillingInfo)
    ] 
   
    /**************************************************************************
     * 13. User selects back link and the appType is b2b.
     */
    action gotoTermsAndConditions[
    	gotoUc(regTermsAndConditions) [
    		sLoginAction : sLoginAction 
    		sAppType: sAppType   		
    	]
    ]
    
    /**************************************************************************
     * 10.1 Display generic error message 
     * 11.1 Display generic error message     
     */
	action genericErrorMsg [
		displayMessage(type: "danger" msg: msgGenericError)
        goto(regLoginInfoScreen)
	]	
]
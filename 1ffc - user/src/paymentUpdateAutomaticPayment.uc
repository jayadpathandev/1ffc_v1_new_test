useCase paymentUpdateAutomaticPayment [
   /**
    *  author: Maybelle Johnsy Kanjirapallil
    *  created: 23-Nov-2016
    *
    *  Primary Goal:
    *       1. Update automatic payment.
    *       
    *  Alternative Outcomes:
    *       1. None 
    *                     
    *   Major Versions:
    *        1.0 23-Nov-2016 First Version Coded [Maybelle Johnsy Kanjirapallil]
    *        2.0 13-Jan-2022 Combine paymentCreateAutomatic to this use case for create. 
    *                        This use case will supports both creating and updating an automatic payment
    */

    documentation [
        preConditions: [[
            1. User is logged in.
        ]]
        triggers: [[
            1. The user clicks the update automatic payment option.
        ]]
        postConditions: [[
            1. Primary -- An automatic payment is updated.
        ]]
    ]
    actors [ 
        create_payment
    ]       
		    
    startAt isB2bUser[sSelectedAutomaticId, sGroupJson, scheduleFoundWithAccount]
    
    /*************************
	* DATA ITEMS SECTION
	*************************/ 	
	importJava AppConfig(com.sorrisotech.utils.AppConfig)
	importJava I18n(com.sorrisotech.app.common.utils.I18n)
	importJava ForeignProcessor(com.sorrisotech.app.common.ForeignProcessor)
	importJava NotifUtil(com.sorrisotech.common.app.NotifUtil)
	importJava Session(com.sorrisotech.app.utils.Session)
	importJava UcPaymentAction(com.sorrisotech.uc.payment.UcPaymentAction)
	importJava LocalizedFormat(com.sorrisotech.common.LocalizedFormat)
			
    import validation.dateValidation
		
	import billCommon.sPayAccountInternal	
	import billCommon.sPayAccountExternal  
	import billCommon.sPayGroup  	   
    import paymentCommon.sDeleteAutomaticMsgFlag
    import paymentCommon.sShowNoChangeMsgFlag
    import paymentCommon.sErrorAutomaticMsgFlag
    import paymentAutomatic.sNickName
    import paymentAutomatic.sPmtSourceId 
    import apiPayment.pmtRequest    
    import apiPayment.setAutomaticPayment
    import apiPayment.getAutomaticPaymentByAccount
    import apiPayment.setAutomaticPaymentHistory
    
	native string sFormat = LocalizedFormat.toJsonString()
    
    string sUpdateAutomaticHeader     = "{Update automatic payment}"
    string sCreateAutomaticHeader	  = "{Create automatic payment}"
    string sScheduleTriggerHeader     = "{Schedule Trigger}"
    string sScheduleTriggerHeaderHelp = "{Select the criteria that will trigger the automatic payment. Please allow up to 3 days for payment to be posted.}"    
    string sScheduleExpiryHeader      = "{Schedule Expiry}"
    string sScheduleExpiryHeaderHelp  = "{Select when you would like the automatic payment to stop.}"
    string sPayAmountHeader           = "{Payment amount}"
    string sPayAmountHeaderHelp       = "{Select how much you want to pay.}"
    string sPaymentMethodHeader       = "{Payment method}"
    string sPaymentMethodHeaderHelp   = "{Choose the payment method for this automatic payment}"
    string sSelectedAutomaticId	      = ""
    string sGroupJson				  = ""	
    volatile string sSafeGroupJson	  =  UcPaymentAction.escapeGroupingJson(sGroupJson)
    
    native string sFuturePaymentsFound = "false"
	native string sHistoryText          = "Automatic payment created." 
	native string sDays                 = ""
    native string sConfigChange         = ""
    native string sPayInvoicesOptionOld = ""
	native string sEffUntilOptionOld    = ""
	native string sPayAmountOptionOld	= ""	
	native string sSourceIdOld          = ""
	native string sPayDateOld           = ""
	native string sPriorDaysOld         = ""
	native string sExpiryDateOld        = ""
	native string sPayCountOld          = ""
	native string sPayUptoOld           = ""
	native string sPayInvoicesOptionNew = ""
	native string sEffUntilOptionNew    = ""
	native string sPayAmountOptionNew	= ""	
	native string sPayDateNew           = ""
	native string sPriorDaysNew         = ""
	native string sExpiryDateNew        = ""
	native string sPayCountNew          = ""
	native string sPayUptoNew           = ""
    native string sSourceIdNew          = ""
    native string sAutomaticPaymentShortcut = ""
    native string sAppUrl           = AppConfig.get("user.app.url")
    native string sNtfParams = "" 
    native string sSendEditEmailFlag = NotifUtil.isNotificationEnabled(sUserId, "payment_automatic_edit_success")
    native string sSendCreateEmailFlag = NotifUtil.isNotificationEnabled(sUserId, "payment_automatic_create_success")
    native string sToken = ""
    native string sPayUpto = UcPaymentAction.getAutoPayUpto()
    native string sThousand = "1000"
    native string sDisplayAmt = UcPaymentAction.formatAmtText(sThousand, sPayGroup, "auto")
    native string sMinimumDueFlag = UcPaymentAction.getMinimumDueFlag()
    native string sBillingType = UcPaymentAction.getBillingBalanceType()
    native string surchargeFlag = UcPaymentAction.getSurchargeStatus()
    
    // from paymentCreateAutomaticPayment
    native string sPayDate      = "1"
    native string sDay          = "2"
    native string sSourceId     = ""
    native string sUserId       = Session.getUserId()
    native string sIsB2b        = Session.isB2bAsString()
    native string sStatusFlag   = ""
                                                   
    field fPayInvoices [
        string(label) sLabel = "{Pay invoices *}"        
        radioSet(control) rInput = option2 [        
            option1: "{of every month}"
            option2: "{prior to 'Due Date'}"              
        ]
        
        string(help) sHelp = "{If 31, 30 or 29 is selected and if it doesn't exist in the month, then the last day of the month will trigger the payment.}"
        auto dropDown(option1_prefix) dPayDate                       
        auto dropDown(option2_prefix) dPayPriorDays 
    ]
    
    field fPayEffective [
        string(label) sLabel = "{Effective until *}"        
        radioSet(control) rInput = option1 [        
            option1: "{I cancel}"
            option2: ""    
            option3: "{payments made}"            
        ]
        
        date(option2_prefix) aDate("yyyy-MM-dd", dateValidation)         
        
        input (option3_prefix) pInput("^[1-9][0-9]?$|^100$", fPayEffective.inputValidation) = "1"  
        string(pInput_validation) inputValidation = "{Enter a number between 1 and 100.}"                
    ]
    
    field fPayAmount1 [
        string(label) sLabel = "{Pay *}"        
        radioSet(control) rInput = option1 [        
            option1: "{Bill balance}"
//            option2: "{Minimum due}"    
 //           option3: "{Up to}"            
        ]
        input (option3_suffix) pInput("^(\\d{1,5}|\\d{0,5}\\.\\d{1,2})$", fPayAmount1.sValidation) = "1"   
        
        string sPayUptoValidationText = "{Enter a number between 1 and <1> (up to 2 decimal values allowed)}"
        volatile string(pInput_validation) sValidation = I18n.translate ("paymentUpdateAutomaticPayment_fPayAmount1.sPayUptoValidationText", sPayUpto)  
        volatile string(error) sError = I18n.translate ("paymentUpdateAutomaticPayment_fPayAmount1.sPayUptoValidationText", sPayUpto)  
        string sText =  "{Warning, entry exceeds}"
        volatile string(error) sWarningText = I18n.translate ("paymentUpdateAutomaticPayment_fPayAmount1.sText")
        volatile string(error) sWarning                          
    ]
    
    field fPayAmount2 [
        string(label) sLabel = "{Pay *}"        
        radioSet(control) rInput = option1 [        
            option1: "{Bill amount}"
//            option2: "{Minimum due}"    
//            option3: "{Up to}"             
        ]
        input (option3_suffix) pInput("^(\\d{1,5}|\\d{0,5}\\.\\d{1,2})$", fPayAmount2.sValidation) = "1"   
        
        string sPayUptoValidationText = "{Enter a number between 1 and <1> (up to 2 decimal values allowed)}"
        volatile string(pInput_validation) sValidation = I18n.translate ("paymentUpdateAutomaticPayment_fPayAmount2.sPayUptoValidationText", sPayUpto)  
        volatile string(error) sError = I18n.translate ("paymentUpdateAutomaticPayment_fPayAmount2.sPayUptoValidationText", sPayUpto)  
        string sText =  "{Warning, entry exceeds}"
        volatile string(error) sWarningText = I18n.translate ("paymentUpdateAutomaticPayment_fPayAmount2.sText")
        volatile string(error) sWarning         
    ]
    
    auto "{Pay using *}" dropDown dWalletItems
                       
   static sEftNotice = "{By authorizing this transaction, you agree that we " +
                       "may convert this transaction into an Electronic Funds Transfer " + 
                       "(EFT) transaction or paper draft, and to debit this account " +
                       "for the amount of the transaction. Additionally, in the event " + 
                       "this draft or EFT is returned unpaid, a service fee, as " +
                       "allowable by law, will be charged to this account via EFT or " + 
                       "draft. In the event you choose to revoke this authorization, " +
                       "please do so by contacting us directly. Please note " +
                       "that processing times may not allow for revocation of this " +
                       "authorization.}"
                       
   static sSurchargeNotice = "{The Surcharge is a processing fee for using a credit card to " +
                             "make payments. This processing fee is no more than our costs " +
                             "associated with accepting credit cards or 4% of the transaction, " +
                             "whichever is less. This fee is not charged when you use a debit " +
                             "card or bank account to make a payment.  To avoid this fee, update " +
                             "your payment method to use a debit card or bank account. Thank you.}"                       
                    
    string sPaymentSurchargeMessage   = "{There will be a credit card processing charge for this order for processing the credit card you have selected to make this purchase. The fee is not greater than our expenses associated with accepting credit card payments. if you have payment notifications enabled, you will be notified of the processing fee when a payment is scheduled.If you would prefer to use a debit card or bank card, then there will be no processing fee.}"  
                    		
    serviceStatus ssStatus  
    serviceResult(SystemConfig.GetCurrentBalanceConfig) srGetComm
        		
    serviceParam(Payment.GetAutomaticPayment) srGetAutomaticParam
	serviceResult(Payment.GetAutomaticPayment) srGetAutomaticResult
			
	serviceParam(Payment.SetAutomaticPayment) srSetAutomaticParam
	serviceResult(Payment.SetAutomaticPayment) srSetAutomaticResult
	
	serviceParam(Payment.SetAutomaticPaymentHistory) srSetAutomaticHistoryParam
	serviceResult(Payment.SetAutomaticPaymentHistory) srSetAutomaticHistoryResult
	
	serviceResult (Payment.GetWalletByToken) srGetWalletInfoResult
	serviceParam (Payment.GetWalletByToken) srGetWalletInfoParam
	
	// move over from B2B
    string scheduleFoundWithAccount = "false"   
       
    string sMsgNumber2 = "{[span] 2 [/span]}" 
    string sMsgNumber3 = "{[span] 3 [/span]}"  
     
    string sAutomaticConfigHeader = "{Setup automatic payments for selected accounts}"
    
    static sPaymentSummaryHeaderPrefix = "{Payment summary - }"
    static sPaymentSummaryHeaderSuffix = "{ selected accounts}"
    static expandedAccounts = "{Expand table}"
    static collapseAccounts = "{Collapse table}"
    static sAccountNumLabel = "{Account #}"
    static sAccountsLabel = "{account(s)}"    
    string step1Content = "Java script failed to execute"    
    
    structure msgAutoPmtScheduled [
        static sTitle = "{Payment warning}"
    ]
    
    structure msgAutoPmtScheduledCreate [
		static sBody = "{There one or more payments schedule for the selected account(s). Creating an automatic payment schedule will NOT override the upcoming payment(s).}"
    ]

    structure msgAutoPmtScheduledEdit [
		static sBody = "{There one or more payments schedule for the selected account(s). Editing this automatic payment schedule will NOT override the upcoming payment(s).}"
    ]

    structure msgAutoNote [
        static sTitle = "{Payment note}"
    ]
    
    structure msgAutoAccAlreadyFound [
        static sBody = "{One or more of the accounts selected have been removed since they are found in one of the automatic schedules for this user.}"
    ]

    structure msgAutoUnableComplete [
        static sBody = "{There are no accounts selected so a schedule cannot be created}"
    ]
    
    structure msgPayWarning [
        static sTitle = "{Payment warning}"
    ]

    structure msgMakeAutoAccAlreadyFound [
        static sBody = "{One or more accounts you have selected have automatic payments configured. Automatic payments pay bills on your behalf, but you can choose to proceed with this manual payment if you choose. Automatic payments will then just pay whatever balance remains.}"
    ]    
    
    structure msgScheduledPaymentWarning [
		string sTitle = "{Payment warning}"  
		static sBody = "{There is at least one existing payment scheduled for account(s) covered by this automatic payment schedule. These payment(s) will not be affected by this new schedule.}"
	] 
	
    	
	/*************************
	* MAIN SUCCESS SCENARIOS
	*************************/

	/* 1. Find out which account has the future scheduled payments */	
	action isB2bUser [
		
		if sIsB2b == "true" then  
			getFutureSchedulePayments
		else 
			init
	]

	/* 2 Get Future Scheduled payments */		 
	action getFutureSchedulePayments [
		switch UcPaymentAction.hasFutureScheduledPayments(sUserId, sGroupJson, sSelectedAutomaticId) [
			case  "true" setFutureSchedulePmtFlag
			case  "false" init
			default  init
		]		
	] 

	/* 3. Set sFutrePaymentsFound flag if found */		
	action setFutureSchedulePmtFlag [
		sFuturePaymentsFound = "true"
		goto(init)
	]

	 /* 1.1. Initialize the usecase. */	
	action init [
		fPayAmount1.sWarning = fPayAmount1.sWarningText + sDisplayAmt
		fPayAmount2.sWarning = fPayAmount2.sWarningText + sDisplayAmt
		
		if sSelectedAutomaticId  != "" then
			initUpdate		
		else
			initCreate
	]
	
	/* 2. Initialize create automatic payment */	
	action initCreate [
		UcPaymentAction.getPayDate(sPayDate, fPayInvoices.dPayDate)		
		UcPaymentAction.getDays(sDay, fPayInvoices.dPayPriorDays)
		UcPaymentAction.getWalletItems(sUserId, sSourceId, dWalletItems)

        switch apiCall SystemConfig.GetCurrentBalanceConfig (srGetComm, ssStatus) [
            case apiSuccess updateAutomaticPaymentScreen
            default updateAutomaticPaymentScreen
        ]		
	] 

	/* 2.1 Initialize update automatic payment */		
	action initUpdate [
		fPayAmount1.sWarning = fPayAmount1.sWarningText + sDisplayAmt
		fPayAmount2.sWarning = fPayAmount2.sWarningText + sDisplayAmt
			
        switch apiCall SystemConfig.GetCurrentBalanceConfig (srGetComm, ssStatus) [
            case apiSuccess getAutoPaymentDetails
            default getAutoPaymentDetails
        ]	    
	]
	
	/* 3. Get automatic payment details.*/ 
    action getAutoPaymentDetails [	
    	srGetAutomaticParam.AUTOMATIC_ID = sSelectedAutomaticId
		srGetAutomaticParam.USER_ID = sUserId
		srGetAutomaticParam.FORMAT_JSON = sFormat
			
		switch apiCall Payment.GetAutomaticPayment(srGetAutomaticParam, srGetAutomaticResult, ssStatus) [
		    case apiSuccess checkMinimumAmtFlag		   
		    default automaticErrorResponse
		]	
	]  
	
	/* 4. Check the minimum amount flag.*/ 
	action checkMinimumAmtFlag [
    	if srGetComm.RSP_CURBALTYPE == "F" then
    		getPayAmount1
    	else
    		getPayAmount2	
    ]
    
    /* 5. Get payment amount 1.*/ 
    action getPayAmount1 [
    	fPayAmount1.rInput = srGetAutomaticResult.PAY_AMOUNT_OPTION
		fPayAmount1.pInput = srGetAutomaticResult.PAY_UPTO
    	goto(getResults)
    ]
    
    /* 5.1. Get payment amount 2.*/
    action getPayAmount2 [
    	fPayAmount2.rInput = srGetAutomaticResult.PAY_AMOUNT_OPTION
		fPayAmount2.pInput = srGetAutomaticResult.PAY_UPTO
		UcPaymentAction.strip(fPayAmount2.pInput)
		
    	goto(getResults)
    ]
    
	/* 6. Get automatic payment details from the results .*/
	action getResults [
		 fPayInvoices.rInput = srGetAutomaticResult.PAY_INVOICES_OPTION
		 sPayDate = srGetAutomaticResult.PAY_DATE
		 sDays = srGetAutomaticResult.PAY_PRIOR_DAYS
		 fPayEffective.rInput = srGetAutomaticResult.EFFECTIVE_UNTIL_OPTION
		 fPayEffective.aDate = srGetAutomaticResult.EXPIRY_DATE
		 fPayEffective.pInput = srGetAutomaticResult.PAY_COUNT
		 		 
		 UcPaymentAction.getPayDate(sPayDate, fPayInvoices.dPayDate)		
		 UcPaymentAction.getDays(sDays, fPayInvoices.dPayPriorDays)
		 UcPaymentAction.getWalletItems(sUserId, sPmtSourceId, dWalletItems)
		 
		 goto (saveCurrentValues)
	]
	
	/* 7. Saves the current automatic payment field values.*/
	action saveCurrentValues [
		
		sPayInvoicesOptionOld  =  srGetAutomaticResult.PAY_INVOICES_OPTION
		sEffUntilOptionOld     =  srGetAutomaticResult.EFFECTIVE_UNTIL_OPTION
		sPayAmountOptionOld	   =  srGetAutomaticResult.PAY_AMOUNT_OPTION		        
        sPayDateOld            =  srGetAutomaticResult.PAY_DATE
        sPriorDaysOld          =  srGetAutomaticResult.PAY_PRIOR_DAYS
        sExpiryDateOld         =  srGetAutomaticResult.EXPIRY_DATE
        sPayCountOld           =  srGetAutomaticResult.PAY_COUNT
        sPayUptoOld            =  srGetAutomaticResult.PAY_UPTO
        sSourceIdOld           = dWalletItems
		goto (updateAutomaticPaymentScreen)
	]

    /* 3. 8. Show the update automatic payment screen. */
    xsltScreen updateAutomaticPaymentScreen("{Payment}") [
    	
    	div editScheduleContainer [
    		class: "col-md-12 st-payment-template-border st-scheduled-payment"
			
	   		h4 headerUpdate [
					class: "col-md-12 st-payment-onetime-header"
					logic: [
						if sSelectedAutomaticId  == "" then "hide"
					]
					display sUpdateAutomaticHeader
			]
			
	   		h4 headerCreate [
					class: "col-md-12 st-payment-onetime-header"
					logic: [
						if sSelectedAutomaticId  != "" then "hide"
					]
					display sCreateAutomaticHeader
			]			
							 			
	    	form updateAutomaticPaymentForm [
		    	class: "row st-payment-padding-bottom"
		    	ng-controller: "ScheduleCtrl"
        		ng-init: "init();"
		    	messages: "top"
		    	
		    	/*-- Step 1 Container - Payment Summary  --*/		    	
		    	div step1_container [
		    		class: "row"
		    		
		    		div step1_container_content [
		    			class: "col-md-12 st-border-bottom ng-scope"
		    			
		    			div step1_container_fill [
		    				class: "row"
		    				
		    				// error message for msgAutoPmtScheduled  
		    				div step1_msgAutoPmtScheduled [
		    					class: "col-md-12 alert alert-warning st-auto-scheduled-warning"
		    					logic: [
							         if sFuturePaymentsFound  == "false" then "remove"
							    ]
							    
							    div step1_msgAutoPmtScheduled_content [
							    	class: "row"
							    	
							    	h4 step1_msgAutoPmtScheduled [
							    		class: "col-md-12"							    		
							    		display msgAutoPmtScheduled.sTitle
							    	]	
							    	
							    	div step1_msgAutoPmtScheduledCreate [
							    		class: "col-md-12"
										logic: [
											if sSelectedAutomaticId  != "" then "hide"
										]							    		
							    		display msgAutoPmtScheduledCreate.sBody
							        ]
							        
							        div step1_msgAutoPmtScheduledEdit [
							    		class: "col-md-12"
							    		logic: [
											if sSelectedAutomaticId  == "" then "hide"
										]
							    		display msgAutoPmtScheduledEdit.sBody
							        ]							    							        							    
							    ]
		    				]
		    				
		    				// error message msgAutoNote
		    				div step1_msgAutoNote [
		    					class: "col-md-12 alert alert-info st-auto-scheduled-warning" 
		    					logic: [
		    						if scheduleFoundWithAccount == "false"   then "remove"
		    					]
		    					
		    					div step1_msgAutoNote_content [
		    						class : "row"
		    						
		    						h4 step1_msgAutoNote_title [
		    						   class: "col-md-12"
		    						   display msgAutoNote.sTitle
		    						]
		    						
		    						div step1_msgAutoAccAlreadyFound_body [
		    							class: "col-md-12"
		    							display msgAutoAccAlreadyFound.sBody
		    						]		    						
		    					]	
		    				]		    			
						]  // end container_fill
		    			    
		    			display step1Content [
		    				attr_sorriso: "element-schedule-step1-content" 
		    				attr_scheduleId: sSelectedAutomaticId		    				
		    				attr_accounts: sSafeGroupJson
		    			]		    					   
					]  
				] /* end step1_container */

				/*-- Step 2 Payment Method --*/		  	   
				div step2_container	[
					class: "row"
					
					div step2_containerCol [
						class: "col-md-12 st-border-bottom ng-scope"
						
						div step2_header [
							class: "row"
							
							h4 paymentMethodHeader [
								display sMsgNumber2 [
									class: "st-payment-step-number "
								]
								display sPaymentMethodHeader [
									class: "st-payment-onetime-header"
								]
							]
						]
					
						div step2_payMethod [
							class: "row st-margin-left45"			
											
							div step2_payMethod_help[
								class:"col-md-12 st-light-label st-padding-bottom"
								display sPaymentMethodHeaderHelp
							] 	
							
							div payUsing [
							class: "col-md-12 st-padding-bottom"
							display dWalletItems [
								class: "st-field-wide"
								control_attr_tabindex: "11"			
								logic: [										
									if "true" == "true" then "disable_expired"				
								]																			
							]
						  ]			
						]
	
						div paymentSurchargeColumn [
							class: "col-md-10 st-margin-left45 visually-hidden" 
							ng-show: "form['surchargeEnabled']=='true'"
												
							div paymentSurchargeMessage [
								class: "col-md-12 alert alert-warning st-padding-bottom"
								display sSurchargeNotice
							]
						]
						
						div eftMessageContent [
							class: "col-md-10 st-margin-left45"
							div eftMessage [
								class: "col-md-12 alert alert-warning visually-hidden st-padding-bottom"
								ng-hide: "methodType != 'bank'"
								
								display sEftNotice
							]							
						]			    			

			        	display sPayUpto [
					    	class: "d-none st-pay-upto"
					    ]
					    
					    display surchargeFlag [
							class: "d-none st-surchargeflag"
						]
                    ]
                ]   // end step 2 container

				/*--  Step 3 - setup automatic payments for selected accounts --*/				
				div step3_container [
					class: "row"
					
					div step3_config_content [
						class: "col-md-12 ng-scope st-update-automatic-payment"
						
						div step3_config_sAutomaticConfigHeader [
							class: "row"
							
						   		h4 configHeader [
									class: "col-md-12"
									display sMsgNumber3 [
										class: "st-payment-step-number "
									]
									display sAutomaticConfigHeader [
										class: "st-payment-onetime-header"
									]
								]	
						 ]
						 
						 div step3_content [
						 	 class: "row st-margin-left45"		
										    
							 div formCol1 [
								 class: "col-lg-4 st-padding-top"
								
								 div scheduleTrigger [
									 class: "col-md-12"
									
									 h4 scheduleTriggerHeader [
										class: "col-md-12"
										display sScheduleTriggerHeader
									 ]
									
									 div scheduleTriggerHeaderHelp [
										 class: "col-md-12 st-light-label st-padding-bottom"
										 display sScheduleTriggerHeaderHelp
									 ]
									
									 div payInvoices [
										 class: "col-md-12 st-field-narrow"
										 display fPayInvoices [
											control_attr_tabindex: "10"
											control_attr_autofocus: ""
										]
									 ]	
								 ]					
							 ]	
									
							 div formCol2 [
								 class: "col-lg-4 st-padding-top"
								
								 div scheduleExpiry [
									 class: "col-md-12"
									
									 h4 scheduleExpiryHeader [
										class: "col-md-12"
										display sScheduleExpiryHeader
									 ]
									
									 div scheduleExpiryHeaderHelp [
										 class: "col-md-12 st-light-label st-padding-bottom"
							 			 display sScheduleExpiryHeaderHelp
									 ]
									
									 div payEffective [
										 class: "col-md-12"
										 display fPayEffective [
											control_attr_tabindex: "12"
										]
									 ]	
								 ]										
							 ]	
							
							 div formCol3 [
								 class: "col-lg-4 st-padding-top"
								
								 div payAmount [
									 class: "col-md-12"
									
									 h4 payAmountHeader [
										class: "col-md-12"
										display sPayAmountHeader
									 ]
									
									 div payAmountHeaderHelp [
										 class: "col-md-12 st-light-label st-padding-bottom"
										 display sPayAmountHeaderHelp
									 ]
									
									 div payAmount1 [
										 class: "col-md-12"
										 logic: [
											if srGetComm.RSP_CURBALTYPE != "F" then "remove"													
										 ]
										 
										 display fPayAmount1 [								
											logic: [										
												if sMinimumDueFlag != "true" then "remove_option2"
												if sBillingType == "invoice" then "remove_option2"
												if sBillingType == "invoice" then "remove_option3"												
											]
											control_attr_tabindex: "12"								
											sWarning_class_override: "st-error alert alert-warning visually-hidden"
											sError_class_override: "st-error alert alert-danger visually-hidden"
											embedded_class: "ms-2"
										]
									 ]
									
									 div payAmount2 [
										 class: "col-md-12"
										 logic: [
											if srGetComm.RSP_CURBALTYPE == "F" then "remove"												
										 ]
										 
										 display fPayAmount2[								
											logic: [										
												if sMinimumDueFlag != "true" then "remove_option2"		
												if sBillingType == "invoice" then "remove_option2"	
												if sBillingType == "invoice" then "remove_option3"									
											]											
											control_attr_tabindex: "12"
											sWarning_class_override: "st-error alert alert-warning visually-hidden"
											sError_class_override: "st-error alert alert-danger visually-hidden"
											embedded_class: "ms-2"
										]
									 ]	
								 ]										
							 ]	
					     ]
				        
				   ]	
				]           // end step 3 container
				
				/* Buttons */
				div buttons [
					class: "st-margin-left45 st-margin-right45"
					
					div buttonsContent [
						class: "row st-payment-buttons"			
						
						div buttonsContent_actions [
							class: "col-12"

							navigation updateAutomaticPaymentButton(checkMinAmtFlag, "{UPDATE AUTOMATIC PAYMENT}") [
								logic: [
									if sSelectedAutomaticId  == "" then "remove"
								]
			                    class: "btn btn-primary"	
			                    ng-disabled: "hasExceededPayUptoAmount() == 'true'"
			                    data :[
			                    	fPayInvoices,
			                    	fPayAmount1,
			                    	fPayAmount2,
									fPayEffective	
			                    ]		        
			                    require: [
			                    	dWalletItems
			                    ]            
			                    attr_tabindex: "14"
			                ]  		               

							navigation createAutomaticPaymentButton(checkMinAmtFlag, "{CREATE AUTOMATIC PAYMENT}") [
								logic: [
									if sSelectedAutomaticId  != "" then "remove"
								]									
				            	class: "btn btn-primary"	
				                ng-disabled: "isSourceEmpty() == 'true' || hasExceededPayUptoAmount() == 'true'"		                    
				                data :[
				                   		fPayInvoices,
				                   		fPayAmount1,
				                   		fPayAmount2,
										fPayEffective										
				                 ]		                    
			                    require: [
			                    	dWalletItems
			                    ]            
				                attr_tabindex: "14"
				           ]  		               
   	
			               navigation cancelPaymentLink(gotoPaymentAutomatic, "{CANCEL}") [
								class: "ms-4 btn btn-secondary st-padding-top"							
								attr_tabindex: "13"
			               ]			                
			            ]					    				    
				    ]	                
				]   	  
			]  
		]	
    ]
    
    /* 9. Check the minimum amount flag.*/ 
    action checkMinAmtFlag [
    	if srGetComm.RSP_CURBALTYPE == "F" then
    		setPayAmount1
    	else
    		setPayAmount2	
    ]

	/* 10. decide whether it is create or update */
	action setPayAmount1 [
		if sSelectedAutomaticId  == "" then
			setCreatePayAmount1
		else
			setUpdatePayAmount1			
	]   

	/* 10.1 decide whether it is create or update */	
 	action setPayAmount2 [
	if sSelectedAutomaticId  == "" then
			setCreatePayAmount2
		else
			setUpdatePayAmount2		
	]	

	/* 11. set pay amount 1*/
    action setCreatePayAmount1 [
    	srSetAutomaticParam.PAY_AMOUNT_OPTION      = fPayAmount1.rInput
		srSetAutomaticParam.PAY_UPTO               = fPayAmount1.pInput		
    	goto(setCreateAutomaticPayment)
    ]

	/* 11.1 set pay amount 1*/     
    action setUpdatePayAmount1 [
    	sPayAmountOptionNew	   =  fPayAmount1.rInput
    	sPayUptoNew            =  fPayAmount1.pInput	
    	srSetAutomaticParam.PAY_AMOUNT_OPTION      = fPayAmount1.rInput
		srSetAutomaticParam.PAY_UPTO               = fPayAmount1.pInput			
    	goto(saveNewValues)
    ]

    /* 12. Set payment amount 2. */
    action setCreatePayAmount2 [
    	srSetAutomaticParam.PAY_AMOUNT_OPTION      = fPayAmount2.rInput
		srSetAutomaticParam.PAY_UPTO               = fPayAmount2.pInput		
    	goto(setCreateAutomaticPayment)
    ]

   /* 12.1 Set payment amount 2. */        
    action setUpdatePayAmount2 [
    	sPayAmountOptionNew	   =  fPayAmount2.rInput
    	sPayUptoNew            =  fPayAmount2.pInput		
    	srSetAutomaticParam.PAY_AMOUNT_OPTION      = fPayAmount2.rInput
		srSetAutomaticParam.PAY_UPTO               = fPayAmount2.pInput
    	goto(saveNewValues)
    ]

    /* 13 Inserts an automatic payment record. */
	action setCreateAutomaticPayment [	    			
		srSetAutomaticParam.GROUPING_JSON          = sGroupJson
		srSetAutomaticParam.SOURCE_ID              = dWalletItems
		srSetAutomaticParam.PAY_INVOICES_OPTION    = fPayInvoices.rInput
		srSetAutomaticParam.PAY_DATE               = fPayInvoices.dPayDate
		srSetAutomaticParam.PAY_PRIOR_DAYS         = fPayInvoices.dPayPriorDays
		srSetAutomaticParam.EFFECTIVE_UNTIL_OPTION = fPayEffective.rInput					
		srSetAutomaticParam.EXPIRY_DATE            = fPayEffective.aDate
		srSetAutomaticParam.PAY_COUNT              = fPayEffective.pInput		
		srSetAutomaticParam.USER_ID                = sUserId
		
		switch apiCall Payment.SetAutomaticPayment(srSetAutomaticParam, srSetAutomaticResult, ssStatus) [
            case apiSuccess setCreateAutomaticPaymentHistory
            default setAutomaticErrorResponse
        ]	
    ]
        
    /* 13.1 Saves automatic payment new field values. */
    action saveNewValues [    	
    	sPayInvoicesOptionNew  =  fPayInvoices.rInput
		sEffUntilOptionNew     =  fPayEffective.rInput		
		sPayDateNew            =  fPayInvoices.dPayDate
		sPriorDaysNew          =  fPayInvoices.dPayPriorDays
		sExpiryDateNew         =  fPayEffective.aDate
		sPayCountNew           =  fPayEffective.pInput		
		sSourceIdNew           =  dWalletItems
		
		switch UcPaymentAction.compareOldAndNewValues(sPayInvoicesOptionOld, sEffUntilOptionOld, sPayAmountOptionOld, sSourceIdOld, sPayDateOld, sPriorDaysOld, sExpiryDateOld, sPayCountOld, sPayUptoOld,
								sPayInvoicesOptionNew, sEffUntilOptionNew, sPayAmountOptionNew, sPayDateNew, sPriorDaysNew, sExpiryDateNew, sPayCountNew, sPayUptoNew, 
								sSourceIdNew, sConfigChange) [
		
			case "no_change" showNoChangeMessage
			case "success"   setAutomaticPayment
			case "error"     automaticErrorResponse			
			default automaticErrorResponse							 	
		]		    	
    ]

	/* 14 Sets automatic payment history.  */
    action setCreateAutomaticPaymentHistory [	    
    	srSetAutomaticHistoryParam.AUTOMATIC_ID = srSetAutomaticResult.AUTOMATIC_ID			
		srSetAutomaticHistoryParam.USER_ID     = sUserId		
		srSetAutomaticHistoryParam.CONFIG_CHANGE = sHistoryText
		
		switch apiCall Payment.SetAutomaticPaymentHistory(srSetAutomaticHistoryParam, srSetAutomaticHistoryResult, ssStatus) [
            case apiSuccess getWalletInfo
            default setAutomaticErrorResponse
        ]	
    ]    
        
    /* 14.1 Shows no change made message. */
    action showNoChangeMessage [
    	 sDeleteAutomaticMsgFlag   = "false"
    	 sShowNoChangeMsgFlag      = "true"
    	 sErrorAutomaticMsgFlag    = "false" 
    	goto(gotoPaymentAutomatic)
    ]

    /* 14.2 Updates a payment schedule record. */
	action setAutomaticPayment [	    					
		srSetAutomaticParam.GROUPING_JSON          = "{\"grouping\": [{\"internalAccountNumber\":\"" + sPayAccountInternal + "\", \"displayAccountNumber\":\"" + sPayAccountExternal + "\", \"paymentGroup\":\"" + sPayGroup + "\"}]}"
		srSetAutomaticParam.OLD_SOURCE_ID          = sPmtSourceId
		srSetAutomaticParam.SOURCE_ID              = dWalletItems
		srSetAutomaticParam.PAY_INVOICES_OPTION    = fPayInvoices.rInput
		srSetAutomaticParam.PAY_DATE               = fPayInvoices.dPayDate
		srSetAutomaticParam.PAY_PRIOR_DAYS         = fPayInvoices.dPayPriorDays
		srSetAutomaticParam.EFFECTIVE_UNTIL_OPTION = fPayEffective.rInput					
		srSetAutomaticParam.EXPIRY_DATE            = fPayEffective.aDate
		srSetAutomaticParam.PAY_COUNT              = fPayEffective.pInput		
		srSetAutomaticParam.USER_ID                = sUserId
		srSetAutomaticParam.AUTOMATIC_ID           = sSelectedAutomaticId
		
		switch apiCall Payment.SetAutomaticPayment(srSetAutomaticParam, srSetAutomaticResult, ssStatus) [
            case apiSuccess setUpdateAutomaticPaymentHistory
            default automaticErrorResponse
        ]	
    ]
 
    /* 14.3 Updates automatic payment history. */
    action setUpdateAutomaticPaymentHistory [	    		
    	srSetAutomaticHistoryParam.AUTOMATIC_ID = srSetAutomaticResult.AUTOMATIC_ID	
		srSetAutomaticHistoryParam.USER_ID     = sUserId		
		srSetAutomaticHistoryParam.CONFIG_CHANGE = sConfigChange
		srSetAutomaticHistoryParam.AUTOMATIC_ID = sSelectedAutomaticId
		
		switch apiCall Payment.SetAutomaticPaymentHistory(srSetAutomaticHistoryParam, srSetAutomaticHistoryResult, ssStatus) [
            case apiSuccess getWalletInfo
            default automaticErrorResponse
        ]	
    ]
    
    /* 15. Get the wallet info for chosen token. */ 
    action getWalletInfo [	
		srGetWalletInfoParam.SOURCE_ID = dWalletItems
		
		if sSelectedAutomaticId  == "" then 
			getCreateWalletInfo
		else
			getUpdateWalletInfo	
	]

	/* 16 getCreateWalletInfo */
    action getCreateWalletInfo [	
		
		switch apiCall Payment.GetWalletByToken(srGetWalletInfoParam, srGetWalletInfoResult, ssStatus) [
		    case apiSuccess setAutomaticSuccessResponse
		    default setAutomaticErrorResponse
		]  
	]

	/* 16.1 getUpdateWalletInfo */	
    action getUpdateWalletInfo [	
		
		switch apiCall Payment.GetWalletByToken(srGetWalletInfoParam, srGetWalletInfoResult, ssStatus) [
		    case apiSuccess automaticSuccessResponse
		    default automaticErrorResponse
		]  
	]	
	
    /* 17. Automatic payment success response. */
    action setAutomaticSuccessResponse [
    	 sToken = dWalletItems
    	 sNickName = srGetWalletInfoResult.SOURCE_NAME
    	 sDeleteAutomaticMsgFlag  = "false"
    	 sShowNoChangeMsgFlag     = "false"
    	 sErrorAutomaticMsgFlag   = "false" 	
    	 sStatusFlag = "addSuccess"	 
    	 
    	 auditLog(audit_payment.automatic_payment_create_success) [
    		primary  : sUserId
            secondary: sUserId
    		sToken
    	 ]
    	
    	switch sSendCreateEmailFlag [
			case "true" sendCreateSuccessEmail
			case "false" gotoPaymentAutomatic			
			default gotoPaymentAutomatic
		]	
	]
		
    /* 17.1 Automatic payment success response. */
    action automaticSuccessResponse [
    	 sToken = dWalletItems
    	 sNickName = srGetWalletInfoResult.SOURCE_NAME
    	 sDeleteAutomaticMsgFlag  = "false"
    	 sShowNoChangeMsgFlag     = "false"
    	 sErrorAutomaticMsgFlag   = "false" 
    	 sStatusFlag = "editSuccess"
    	 
    	 auditLog(audit_payment.automatic_payment_update_success) [
    		primary  : sUserId
            secondary: sUserId
    		sToken
    	 ]
    	 
    	 switch sSendEditEmailFlag [
			case "true" sendEditSuccessEmail
			case "false" gotoPaymentAutomatic			
			default gotoPaymentAutomatic
		]	
	]

	/* 18 Send create success email */
	action sendCreateSuccessEmail [		
		sNtfParams = "accountNumber=" + sPayAccountExternal
		NotifUtil.sendRegisteredUserEmail(sUserId, sNtfParams, "payment_automatic_create_success")		
		goto(gotoPaymentAutomatic)
	]
		
	/* 18.1 Sends edit success email. */
	action sendEditSuccessEmail [
		sNtfParams = "accountNumber=" + sPayAccountExternal
		NotifUtil.sendRegisteredUserEmail(sUserId, sNtfParams, "payment_automatic_edit_success")	
		
		goto(gotoPaymentAutomatic)
	]


    /* 19. Go to the payment automatic usecase. */
    action gotoPaymentAutomatic [	
    	
    	displayMessage(type: "warning" msg: msgScheduledPaymentWarning)

    	sAutomaticPaymentShortcut = sAppUrl + "startAutomaticPayment?status=" + sStatusFlag + "&futurePmtFlag=" + sFuturePaymentsFound
		foreignHandler ForeignProcessor.writeResponse(sAutomaticPaymentShortcut)
	]	
			
	/*-- Automatic payment error response. --*/	
    action setAutomaticErrorResponse [
    	 sToken = dWalletItems
    	 sDeleteAutomaticMsgFlag  = "false"
    	 sShowNoChangeMsgFlag     = "false"
    	 sErrorAutomaticMsgFlag   = "true" 
    	 sStatusFlag = ""
    	 
    	 auditLog(audit_payment.automatic_payment_create_failure) [
    		primary  : sUserId
            secondary: sUserId
    		sToken
    	 ]
    	 
		 goto(gotoPaymentAutomatic)
	]	
 
    action automaticErrorResponse [
    	 sToken = dWalletItems
    	 sDeleteAutomaticMsgFlag  = "false"
    	 sShowNoChangeMsgFlag     = "false"
    	 sErrorAutomaticMsgFlag   = "true" 
    	 sStatusFlag = ""
    	 
    	 auditLog(audit_payment.automatic_payment_update_failure) [
    		primary  : sUserId
            secondary: sUserId
    		sToken
    	 ]
    	 
		 goto(gotoPaymentAutomatic)
	]
]
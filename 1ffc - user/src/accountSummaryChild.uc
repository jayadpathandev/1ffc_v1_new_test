useCase accountSummaryChild [
	/**
	* author: Maybelle Johnsy Kanjirapallil
	* created: 10-Feb-2016
	*
	* Primary Goal:
	* To display summary of the account.
	*
	* Alternative Outcomes:
	* 1. No recent bill is available
	*
	* Major Versions:
	* 1.0 	10-Feb-2016 First Version Coded [Maybelle Johnsy Kanjirapallil]
	* 2.0 	2023-Dec-11 jak 	Modified from the interim version that Yvette updated
	* 							so it meets 1st Franklin data variability and status 
	* 							requirements.
	* 2.1 	2023-Dec-28 jak		Modified to set payment rules for payment use cases
	* 2.11	2024-Mar-15	jak		Fixed defect in setting number of days out for future payment.
	*/

    documentation [
        preConditions: [[
            1. The endUser can successfully log into the system.
        ]]
        triggers: [[
            1. The endUser successfully logs in and lands on the overview as a default.
            2. The endUser has clicked the "Corresponded" menu.
        ]]
        postConditions: [[
            1. The endUser can view the account summary.
        ]]
    ]
    actors [
        view_document
        view_bill
    ]

	actorRules [
		if "accessDenied" == sLocalAccountStatus removeActor account_access_enabled
		if "accessDenied" != sLocalAccountStatus addActor account_access_enabled
		if "disabled" == sLocalCreatePaymentStatus removeActor create_new_payment_enabled
		if "disabled" != sLocalCreatePaymentStatus addActor create_new_payment_enabled
		if "false" == sAchEnabledStatus removeActor bank_payment_enabled
		if "true" == sAchEnabledStatus addActor bank_payment_enabled
		if "false" == bAutomaticPaymentEnabled removeActor automatic_payment_enabled
		if "true" == bAutomaticPaymentEnabled addActor automatic_payment_enabled
	]
    startAt selectAccount[sParent]   

    /*************************
	* DATA ITEMS SECTION
	*************************/     
	importJava Session(com.sorrisotech.app.utils.Session)
//	importJava UcPaymentAccountBalance(com.sorrisotech.uc.payment.UcPaymentAccountBalance)
//	importJava UcPaymentAction(com.sorrisotech.uc.payment.UcPaymentAction)
	importJava Format(com.sorrisotech.common.app.Format)
	importJava AppConfig(com.sorrisotech.utils.AppConfig)
	importJava LocalizedFormat(com.sorrisotech.common.LocalizedFormat)	
	importJava UcBillingAction(com.sorrisotech.uc.bill.UcBillingAction)
//	importJava FlexFieldInfo(com.sorrisotech.fffc.user.FlexFieldInformation)
	importJava FFFCSession(com.sorrisotech.fffc.user.FFFCSession)

	// -- specific to 1st Franklin ... helps calculate current balance --
	importJava CurrentBalanceHelper (com.sorrisotech.fffc.payment.BalanceHelper)
	importJava DisplayAccountMasked(com.sorrisotech.fffc.account.DisplayAccountMasked)    
				
    import billCommon.sBillAccountInternal
    import billCommon.sBillAccountExternal
    import billCommon.sBillSelectedDate
	import billCommon.sBillGroup
	import billCommon.sBillStream
	import billCommon.sBillVersion
	import billCommon.sBillingPeriod
	import billCommon.sBillsFound
	import billCommon.sSelectedDropDown
	import billCommon.bAccountDelinquent
	import billCommon.nMinimumPayment
	import billCommon.nMaximumPayment
	import billCommon.bMaximumPaymentEnabled
	
	
	import billCommon.sPayAccountInternal
	import billCommon.sPayAccountExternal	
	import billCommon.sPayGroup
	import billCommon.sPayIsBill
	import billCommon.sPaySelectedDate

	
    // -- GetStatus returns the status for all major conditions and business
    //		drivers --
    serviceStatus srAccountStatusCode
    serviceParam (AccountStatus.GetStatus) srGetStatusParams
    serviceResult (AccountStatus.GetStatus) srGetStatusResult
    native string sLocalAccountStatus = "accountClosed"
    native string sLocalAccountStatusDate
    native string sLocalAccountStatusAmount
    native string sLocalAccountBillDate
    native string sLocalAccountBillAmount
	native string sPaymentButtonOn = "false"
	native string sLocalCreatePaymentStatus = "disabled"
	native string sAchEnabledStatus = "true"
	native string sMaxPaymentEnabled = "true"	// -- this is true for 1FFC
	native string bAutomaticPaymentEnabled = "true"

	// -- for testing contracted monthly payment --
	number nContractedPayment
	serviceStatus srGetContractedPaymentStatus
	serviceParam (AccountStatus.GetContractualMonthlyPaymentAmount) spGetContractedPaymentParams
	serviceResult (AccountStatus.GetContractualMonthlyPaymentAmount) srGetContractedPaymentResult
	
		
	// -- Information used for maaximum future payment days --
	// -- retrieve app-config file setting --
	native string sMaxFuturePaymentDays = AppConfig.get("payment.scheduled.date.window", "45")
	// -- target variable paymentOneTime.uc uses to set the calendar --
	import paymentCommon.sScheduledDateWindow 


    
    
//	  serviceStatus srStatus	
//    serviceResult(SystemConfig.GetCurrentBalanceConfig) srGetComm
    
    serviceStatus srBillOverviewStatus
    serviceParam(Documents.BillOverview) 	srBillOverviewParam
    serviceResult(Documents.BillOverview) 	srBillOverviewResult    
    
    native string maxAge =			 		AppConfig.get("recent.number.of.months", "3")
    native string sBillDate =		 		Format.formatDateNumeric(srBillOverviewResult.docDate)
    native string sBillDueDateDisplay = 	Format.formatDateNumeric(srBillOverviewResult.dueDate)
	
	// -- returns a current balance calculated based on either bill or status (whichever is newer) less
	//		payments since that last bill or status date (date inclusive) --
	volatile string sBillAmountDueDisplay = 
			CurrentBalanceHelper.getCurrentBalanceFormattedAsCurrency (
				srBillOverviewParam.payGroup, 
				srBillOverviewParam.account,
				sLocalAccountBillDate,
				sLocalAccountBillAmount,
				sLocalAccountStatusDate,
				sLocalAccountStatusAmount )	 
	
	// -- returns true if the acount is current i.e. current balance <= 0 --
	volatile string bIsAccountCurrent = CurrentBalanceHelper.isAccountCurrent (
				srBillOverviewParam.payGroup, 
				srBillOverviewParam.account,
				sLocalAccountBillDate,
				sLocalAccountBillAmount,
				sLocalAccountStatusDate,
				sLocalAccountStatusAmount )	 
														 // --   set in the admin app --
	native string sCurrentBalanceCalculatedValid // -- set to valid or zero --
    volatile native string sBillAccountBalanceDisplayed = 	LocalizedFormat.formatAmount(srBillOverviewParam.payGroup, srGetStatusResult.accountBalance)
    
	string sUserId = Session.getUserId()
    string sAccNumLabel             = "{Account number:}"
    string sTotDueHead      		= "{Current amount due}"   
	string sInvDueDateLabel			= "{Monthly payment due date}"		
	string sLoanAmountLabel         = "{Current loan balance}"
	

                
	native string sBalanceType	 
	native string sPaymentFlag      = Session.arePaymentsEnabled()
	native string sMultipleAccounts = Session.multipleAccounts()
	
	volatile string sOlderThanXMonths = UcBillingAction.checkBillAge(maxAge, srBillOverviewParam.billDate)
	
	native string sAccountDisplay
	native string sIsBill		// not being used, does this mean if there's no bill we don't work?
	
	// -- variables for holding nickname or last 4 masked display account --
	native volatile string sDisplayAccountNickname = DisplayAccountMasked.displayAccountLookup(sUserId,sBillAccountInternal,sPayGroup)
	
	persistent native string sParent	
		
	auto dropDown dAccounts 		[ FFFCSession.getAllDisplayAccountMasked() ]
	    
    structure(message) msgBillError [
        string(title) sTitle = "{Error}"
        string(body) sBody = "{There was an error while trying to access your most recent bill, please try again later.}"
    ]
    
    structure(message) msgStatusError [
        string(title) sTitle = "{Error}"
        string(body) sBody = "{There was an error retrieving status information for your account, please try again later.}"
    ]
    
    // -- message for screen when we don't have any data or showing data is inappropriate --
    string sMessageClosedAccount = "Congratulations! You've paid off this loan and the account is now closed."
    string sMessageNewAccount = "Thank you for opening your loan with 1st Franklin, we'll notify you when your first statement is available."
    string sMessageAccessDenied = "Your online account access is disabled. Visit or call your local branch immediately to make payment arrangements."
    string sMessageNoBillFound = "Our apologies, we can't find a recent bill for your account."
	
	/*************************
	* MAIN SUCCESS SCENARIOS
	*************************/

	/* 1. System retrieves the account selected.*/	
	action selectAccount[
		dAccounts = sSelectedDropDown
		Session.getAccount(dAccounts, srBillOverviewParam.account)
		Session.getAccountDisplay(dAccounts, sAccountDisplay)
		Session.getPayGroup(dAccounts, srBillOverviewParam.payGroup)
		Session.getIsBill(dAccounts, srBillOverviewParam.isBill)
		Session.getLatestBillDate(dAccounts, srBillOverviewParam.billDate)
		goto (getAccountStatus)
	]

	/****************************************************************************************
	 * BEGIN 1ST FRANKLIN SPECIFIC -- MANAGING BASIC ACCOUNT STATUS - CAN THEY VIEW THIS ACCT
	 * 		AND GATHERING OTHER STATUS INFORMATION FOR TESTS BELOW
	 ************************************************************************************** */
	 
	/**
	 *	1a. System retrieves status information associated with this account. This status 
	 * 		information is used to drive the behavior of this use case and the behavior of 
	 * 		the screen that's displayed.  The status information is specific to 1st 
	 * 		Franklin.
	 */ 
	action getAccountStatus [
		sLocalAccountStatus = "enabled"	// initialize status variable
		sLocalCreatePaymentStatus = "enabled" // initialize create payment status variable
		srGetStatusParams.user = sUserId
		srGetStatusParams.paymentGroup = srBillOverviewParam.payGroup
		srGetStatusParams.account = srBillOverviewParam.account
		// -- retrieve the status information --
   		switch apiCall AccountStatus.GetStatus(srGetStatusParams, srGetStatusResult, srAccountStatusCode) [
    		case apiSuccess checkAccountViewStatus
    		default actionBillProblem
    	]
 	]
 	
 	/**
 	 * 2a. System assigns a local status so it can be used to drive application behavior around account access.
 	 * 		System evaluates actors to set the initial state, then determines if the user can view this account.
 	 * 		If yes, then continue. If not, then the page is disabled and we don't really care why. 
 	 * 		If disabled, nothing else matters... .
 	 * 
 	 */
 	 action checkAccountViewStatus [
 	 	sLocalAccountStatus = srGetStatusResult.accountStatus
 	 	sLocalAccountStatusDate = srGetStatusResult.statusDate
 	 	sLocalAccountStatusAmount = srGetStatusResult.currentAmountDue
		evalActors()
 	 	if "enabled" == srGetStatusResult.viewAccount then
 	 		getPaymentEnabled
 	 	else 
 	 		setStatusAccessDenied
 	 ]
 	 
 	 /**
 	  * 3a. System determined that account access is denied, nothing else matters at this point. System
 	  * 	sets a virtual account status, evaluates actors based on the change and branches to show
 	  * 	to the access denied screen.
 	  */
 	 action setStatusAccessDenied [
 	 	sLocalAccountStatus = "accessDenied"
 	 	evalActors()
 	 	goto (screenShowInfo)
 	 ]
 	 
 	/**************************************************************************************
	 * END 1ST FRANKLIN SPECIFIC -- MANAGING BASIC ACCOUNT STATUS
	 ************************************************************************************** */
 
	/**************************************************************************************
	 * BEGIN 1ST FRANKLIN SPECIFIC -- MANAGING BASIC PAYMENT STATUS
	 ************************************************************************************** */

 	 /**
 	  * 4a. System evaluates payment status to determine if creating new payments should be disabled
 	  * 	and removes the create_payment actor from the user's list of current actors if payment is
 	  * 	disabled.
 	  */
 	 action getPaymentEnabled [
		 	 	
 	 	switch srGetStatusResult.paymentEnabled [

    		// -- user can pay against this account --
    		case "enabled" setDelinquentFalse
    		
    		// ------------------------------------------------------------
			// -- payment is disabled because this is the last bill --
    		case "disabledLastPayment" setLastPaymentRules
    		
    		// ------------------------------------------------------------
			// -- payment is disabled because the customer is delinquent
			// -- at 1FFC, this means they need to make a minimum payment
			//		but does NOT disable payment --
    		case "disableDQ" setDelinquentTrue
    		
 	 		default setPaymentDisabled
 	 	]
 	 ]
 	 
 	 /**
 	  * 5a. For now, or disabledLastPayment rule is to disable payments.
 	  * 	This may change in the future, or this status will disappear.
 	  */
 	 action setLastPaymentRules [
 	 	goto (setPaymentDisabled)
 	 ]
 	 
 	 /**
 	  * 6a. System marks account delinquent and turns off scheduled payments
 	  * 		sScheduledDateWindow =0. This will be checked again when the 
 	  * 		system checks to see if the user has brought the account current
 	  */
 	action setDelinquentTrue [
		bAccountDelinquent = "true"
		sScheduledDateWindow = "0" 
		goto(setMinMaxPayment)
	]
	
	/**
	 * 6b. System marks account not delinquent (i.e. current) and allows future
	 * 			payments. This will be checked again later.
	 */
	action setDelinquentFalse [
		bAccountDelinquent = "false"
		sScheduledDateWindow = sMaxFuturePaymentDays 
		goto(setMinMaxPayment)
	]

	/** 6c. set max payment amount. We get the minimum value a 
	 * 			bit later after we check how much we owe... 
	 *			somewhere just before putting up the screen
	 **/
	action setMinMaxPayment [
		nMaximumPayment = srGetStatusResult.maximumPaymentAmount
		bMaximumPaymentEnabled = sMaxPaymentEnabled
		goto (isAchEnabled)
	]

 	/**
 	 * 7a. System determined that payment is disabled so it removes create new payments from the  
 	 * 	user's list of actors.
 	 */
	action setPaymentDisabled [
 	 	sLocalCreatePaymentStatus = "disabled"
 	 	evalActors()
 	 	goto (isAchEnabled)
 	 ]

	/**************************************************************************************
	 * END 1ST FRANKLIN SPECIFIC -- MANAGING BASIC PAYMENT STATUS
	 ************************************************************************************** */

	/**************************************************************************************
	 * BEGIN 1ST FRANKLIN SPECIFIC -- IS ACH ENABLED OR NOT
	 ************************************************************************************** */
 	 
 	 /**
 	  * 8a. System checks to see if ACH is enabled.
 	  */
 	 action isAchEnabled [
 	 	switch srGetStatusResult.achEnabled [
 	 		case "enabled" isThereALatestBill
 	 		default disableAchPayments
 	 	]
 	 ]

 	 /**
 	  * 8b. ACH disabled, set the proper control and evaluate actors
 	  */
 	 action disableAchPayments [
 	 	sAchEnabledStatus = "false"
 	 	evalActors()
 	 	goto (isThereALatestBill)
 	 ]

	/**************************************************************************************
	 * END 1ST FRANKLIN SPECIFIC -- IS ACH ENABLED OR NOT
	 ************************************************************************************** */


	/**************************************************************************************
	 * BEGIN STANDARD BILL CHECKS FROM PRODUCT
	 ************************************************************************************** */

 	 /** 
 	  * 10a. System checks latest bill date for 0 as a proxy for no documents available. This is
 	  * 	 because Documents.getBillOveriew throws an exception if there are no documents.
 	  * 	 billDate (is zero when there aren't any recent bills). ?? should we fix getBillOverview ??
 	  */
 	 action isThereALatestBill [
 	 	if "0" == srBillOverviewParam.billDate then
 	 		IsActiveNoBill
 	 	else
 	 		isTheBillTooOld
 	 ]
 	 
 	 /**
 	  * 11a. System found a "recent bill", but that's just what's in the database. App-config has a 
 	  * 	setting that the system checks against because the configuration can set a maximum
 	  * 	age for a valid recent bill.
 	  */
 	 action isTheBillTooOld [
 	 	if "true" == sOlderThanXMonths then
 	 		IsActiveNoBill
 	 	else
 	 		getBillOverview
 	 ]
 	 
 	 /**
 	  * 12a. System determines if the account is active and there are no recent bills.
 	  * 		This sets a special state.  Other states are automatic.
 	  */
 	 action IsActiveNoBill [
 	 	if "activeAccount" == sLocalAccountStatus then 
 	 		setActiveNoBill
 	 	else
 	 		screenShowInfo
 	 ]
 	 
 	 /**
 	  * 13a. System sets status to activeNoBill (a "virtual" account status) to drive the 
 	  * 		message screen differently than a standard account status. 
 	  */
 	 action setActiveNoBill [
 	 	sLocalAccountStatus = "activeNoBill"
 	 	goto(screenShowInfo)
 	 ]
	
	/**
	 *  14a. System retrieves the most recent bill overview or multiple, or marks as "nodocs".
	 */			
	action getBillOverview [		
		srBillOverviewParam.user = sUserId
		
	    switch apiCall Documents.BillOverview(srBillOverviewParam, srBillOverviewResult, srBillOverviewStatus) [
		   case apiSuccess howManyDocs
	       default actionBillProblem
	    ]	
	]		
 	
 	/**
 	 * 15a. System expects a single recent bill. If there's more than one, that's an issue.
 	 */
 	action howManyDocs [
 		switch srBillOverviewResult.result [
			case "noDocs" 		screenShowInfo
			case "singleDoc"	checkStatusOneDoc
			default actionBillProblem
 		]
 	]

	/**************************************************************************************
	 * END STANDARD BILL CHECKS FROM PRODUCT
	 ************************************************************************************** */
	
	/**************************************************************************************
	 * BEGIN 1ST FRANKLIN SPECIFIC - TRANSITION FROM STATUS NEW ACCOUNT TO ACTIVE ACCOUNT
	 * 		TRIGGERED BY BILL ARRIVAL
	 ************************************************************************************** */

	/**
	 * 16a. System found "singleDoc" if account status is newAccount or activeAccount, 
	 * 		system needs to determine if payment is enabled for this account (next step). 
	 * 		If account is closed, system goes right to the message screen.
	 */ 
	action checkStatusOneDoc [
		switch sLocalAccountStatus [
			case "newAccount" 		checkPaymentState	
			case "activeAccount" 	checkPaymentState
			case "closedAccount"	screenShowInfo
			default actionBillProblem
		]
	] 	


 	/**
 	 *  17a. System asserts this is an active account since there is a new document.
 	 * 		  system checks to see if payment is enabled and will disabled the payment
 	 * 		  button (next step) if it is not enabled.
 	 * 
 	 * 		Note, the system can assert that this is an activeAccount since
 	 * 			it only arrived at theis action because it is active or new and we
 	 * 			have a single most recent doc. A newAccount with a
 	 * 			doc transitions to an active account.
 	 */
 	 action checkPaymentState [
 	 	sLocalAccountStatus = "activeAccount"
 		sPaymentButtonOn = "true"
 		switch srGetStatusResult.paymentEnabled [
 			case "enabled"	checkResult
 			case "disableDQ" checkResult // -- delinquent isn't really turned off, just sets minimum payment amount
 			default turnOffPaymentButton
 		]
 	]
 	
 	/**
 	 *  18a. System identified one of the "disabled states" and turns payment button off.
 	 */
 	action turnOffPaymentButton [
 		sPaymentButtonOn = "false"
 		goto(checkResult)
 	]

	/**************************************************************************************
	 * END 1ST FRANKLIN SPECIFIC - TRANSITION FROM STATUS NEW ACCOUNT TO ACTIVE ACCOUNT
	 * 		TRIGGERED BY BILL ARRIVAL
	 ************************************************************************************** */

		
	/* 3. Get results from BillOverview call */
	action checkResult [
	    switch srBillOverviewResult.result [
	        case "singleDoc"    loadLatestBill
	        case "noDocs"       hidePdfLink
	        case "multipleDocs" hidePdfLink
	    ]
	]

	/**************************************************************************************
	 * BEGIN STANDARD PRODUCT
	 ************************************************************************************** */
	
	/* 4. Load the latest bill data into screen elements. */
    action loadLatestBill [    
        sBillAccountInternal     	= srBillOverviewParam.account   	// internalAccount
        sBillAccountExternal 		= sAccountDisplay               	// externalAccount
        sBillGroup         			= srBillOverviewParam.payGroup		// payment group for this account
        sBillingPeriod          	= sBillDate					 		// ubf:billdate -- date the bill was published, formatted
		sLocalAccountBillDate		= srBillOverviewResult.docDate		// used when calculating current balance
		sLocalAccountBillAmount		= srBillOverviewResult.totalDue		// used when calculating current balance
        sBillStream 				= srBillOverviewResult.docStream	// bill stream name for this account
        sBillVersion 				= srBillOverviewResult.docVersion 	// document version for this account
        sIsBill						= srBillOverviewParam.isBill		// true if this is a bill, otherwise we are look at a doc.
        
        sPayAccountInternal         = srBillOverviewParam.account 		// used when making payment?  
        sPayAccountExternal 		= sAccountDisplay                	// used when showing in payment?
        sPayGroup         		    = srBillOverviewParam.payGroup		// used when making payment?
        sPaySelectedDate			= srBillOverviewResult.docDate		// used when making payment (unformatted)
        			
		goto(areAutomaticPaymentsEnabled) /** WE SKIP RIGHT OVER THE CURRENT BALANCE CHECK AND GO TO SCREEN */
	]

	/**************************************************************************************
	 * END STANDARD PRODUCT
	 ************************************************************************************** */
	
	/**************************************************************************************
	 * BEGIN-END REMOVED STANDARD PRODUCT CURRENT BALANCE CALCULATION. IT IS CALCULATED DIFFERENTLY
	 * 		FOR FIRST FRANKLIN SO WE DON'T NEED THAT CODE
	 ************************************************************************************** */
	/**************************************************************************************
	 * BEGIN 1ST FRANKLIN SPECIFIC -- ARE AUTOMATIC PAYMENTS ENABLED OR NOT
	 ************************************************************************************** */

	/**
	 *  4a. System checks to see if automatic payments should be on or off 
	 */
	action areAutomaticPaymentsEnabled [
		bAutomaticPaymentEnabled = "true" // -- assume they are enabled --
		switch srGetStatusResult.automaticPaymentStatus [
			case	eligible				setAutomaticPaymentEnabled 		// -- can sign up for recurring payment
			case    enrolled				setAutomaticPaymentEnabled 		// -- already enrolled in a recurring payment 
			case    disabled				setAutomaticPaymentDisabled 	// -- cannot enroll for recurring payment
			case    disabledUntilCurrent 	isAccountCurrent				// -- can enroll if they bring their account current
			default							setAutomaticPaymentEnabled		// -- leave it on if we have unknown status
		]
	] 
	
	/**
	 * 4b. System checks if the account is current. If account is current, system turns automatic payments back
	 		on.
	 */
	action isAccountCurrent [
		bAutomaticPaymentEnabled = bIsAccountCurrent
		evalActors()
		goto (checkIfFuturePaymentNeedsUpdate)
	]
	
	/**
	 * 4c. System disables automatic payments based on status above
	 */
	action setAutomaticPaymentDisabled [
		bAutomaticPaymentEnabled = "false"
		evalActors()
		goto (screenShowInfo)
	]
	
	/**
	 * 4d. System enables autoamtic payments based on status above 
	 */
	action setAutomaticPaymentEnabled [
		bAutomaticPaymentEnabled = "true"
		evalActors()
		goto (checkIfFuturePaymentNeedsUpdate)
	]
	
	/**
	 * 4e. If the account is current, the system makes certain that
	 *		scheduled payments are turned on. 
	 */
	action checkIfFuturePaymentNeedsUpdate [
		if "true" == bIsAccountCurrent then
			setMaxDaysFuturePayment
		else
			screenShowInfo
	]
	
	/**
	 * 4f. System turns scheduled payments back on
	 */
	action setMaxDaysFuturePayment [
		sScheduledDateWindow = sMaxFuturePaymentDays
		goto (screenShowInfo)
	]
	
	/**************************************************************************************
	 * END 1ST FRANKLIN SPECIFIC -- ARE AUTOMATIC PAYMENTS ENABLED OR NOT
	 ************************************************************************************** */

	/**************************************************************************************
	 * BEGIN MOSTLY STANDARD PRODUCT FOR REMAINDER OF USE CASE -- A COUPLE OF SCREEN VARIABLE
	 *  CHANGES FOR BALANCE UPDATES IN FIRST FRANKLIN
	 ************************************************************************************** */

    /* 8. Show the user's greeting message and latest bill information (if found). */
    xsltScreen screenShowInfo("{Greeting and recent information}") [

    form accountSummaryForm [
       	class: "st-account-filter"    
       		
       div summary [
            class: "row st-dashboard-summary"
            
            div info [
            	class: "col-8 col-sm-9 col-lg-10 row"

	            div accountCol [
	            	class: "col-12 col-lg-3 st-summary-account"	   
	            	
 	            	display sAccNumLabel [
	                	class: "st-dashboard-summary-label"
	            		append_space: "true"
	            	] 
	            	
                	display sDisplayAccountNickname [
                		class: "st-dashboard-summary-value"
                		logic: [ if sMultipleAccounts == "true" then "remove" ]		                	
                	]
                	
	    		    display dAccounts [
						class: "d-inline form-control-sm form-select-sm st-dropdown-control"
						ontrol_attr_autofocus: ""
						auto_submit: "submit"
	            		logic: [ if sMultipleAccounts == "false" then "remove" ]		                	
	            	]
	            	navigation submit(submitSelectedAccount, "{Submit}") [
		                class:    "btn btn-primary d-none"
		                validate: "false"
			            data: [ dAccounts ]
	    		    ]	       		                	                		            	
	            ]
	            
	            div loanState [
	            	class: "row col-12 col-lg-3 st-summary-loan-state text-lg-center"
					logic: [ if "activeAccount" != sLocalAccountStatus then "remove"]
	            	display sBillAccountBalanceDisplayed [  // -- this is the current account balance
	            											//		from the status feed so can change "daily" --
	            		class: "h3 st-dashboard-summary-value"
	                ]
	            	
	            	display sLoanAmountLabel [
	                	class: "st-dashboard-summary-label"
	            	] 	            	
	            ]
				    
				div payDate [
					class: "row col-12 col-lg-3 st-summary-date text-lg-center"
					logic: [ if "activeAccount" != sLocalAccountStatus then "remove"]

					display sBillDueDateDisplay [ // -- this is the due date for this bill
	            		class: "h3 st-dashboard-summary-value d-lg-block"
	                ]				
						            	
	                display sInvDueDateLabel [			              			 				                				                	
	                	class: "st-dashboard-summary-label d-lg-block"
	                ]
	
				]        
	
				div payAmount [
					class: "row col-12 col-lg-3 st-summary-amount text-lg-center"
					logic: [ if "activeAccount" != sLocalAccountStatus then "remove"]

	                display  sBillAmountDueDisplay [  // -- this changes when payments are made.. 
	                								  // 		look at declaration (its volatile) --
                   		class: "h3 st-dashboard-summary-value d-lg-block"
	                ]
	            	
	                display sTotDueHead [
	                	class: "st-dashboard-summary-label d-lg-block"
	                ]
				]
				// -- messages only, no data for accounts. Shows a message based on the account status
				//		including a couple of status values that are set ONLY inside this use case. -- 
				div showMessage [
					class: "row col-8 col-lg-8 st-summary-amount text lg-center"
					
					logic: [ if "activeAccount" == sLocalAccountStatus then "remove"]
					
					// -- message for a new account --
					display sMessageNewAccount [
	            		class: "st-dashboard-summary-value text-center"
	            		logic: [if "newAccount" != srGetStatusResult.accountStatus then "remove"]
					]
					
					// -- message for a closed account --
					display sMessageClosedAccount [
	            		class: "st-dashboard-summary-value text-center"
	            		logic: [if "closedAccount" != sLocalAccountStatus then "remove"]
					]
					
					// -- message for an account with access denied ("virtual" account status set
					//		by the use case, not from api call) --
					display sMessageAccessDenied [
	            		class: "st-dashboard-summary-value text-center"
	            		logic: [if "accessDenied" != sLocalAccountStatus then "remove"]
					]
					
					// -- message for case where no bill is found but account is active ("virtual
					//		account status set by the use case, not from api call) --
					display sMessageNoBillFound [
						logic: [if "activeNoBill" != sLocalAccountStatus then "remove"]
	            		class: "st-dashboard-summary-value text-center"
					]
						
				]
				
			]  
			
			// -- we need two payNow buttons because the "disabled" logic doesn't
			//		seem to work on buttons right now --      
			div payNow [
				class: "col-4 col-sm-3 col-lg-2 st-summary-pay-now float-end"
 
				logic: [ 
					if sPaymentButtonOn == "false" then "remove"
					if sParent == "payment_onetime" then "hide"
					if sParent == "payment_automatic" then "hide"
					if sParent == "payment_history"	then "hide"
					if sParent == "payment_wallet"	then "hide"
				]
        		navigation payNowLink(gotoPaymentOnetime, "{Pay This Bill}") [
					class: "btn btn-primary"
					
													
					logic: [
						if sPaymentButtonOn == "false" then "disabled"
	                ]
	                attr_tabindex: "2"
				]
			]  // -- end div payNow --      

			div payNowDisabled[
				class: "col-4 col-sm-3 col-lg-2 st-summary-pay-now float-end"
 
				logic: [
					if sPaymentButtonOn == "true" then "remove"
                	if sParent == "payment_onetime" then "hide"			                	
					if sParent == "payment_automatic" then "hide"
					if sParent == "payment_history"	then "hide"
					if sParent == "payment_wallet"	then "hide"
                ]
				
        		navigation payNowLinkDisabled(gotoPaymentOnetime, "{Pay This Bill}") [
					class: "btn btn-primary disabled"
	                attr_tabindex: "2"
				]
			]  // -- end div payNow --      
        ] // -- end div summary
	 ]
    ]		    

   /* 11. Action to submit the date and redirect to parent screen.*/
    action submitSelectedAccount [    	    
    	sSelectedDropDown = dAccounts  	
		Session.getAccount(dAccounts, sPayAccountInternal)
		Session.getAccountDisplay(dAccounts, sPayAccountExternal)
		Session.getPayGroup(dAccounts, sPayGroup)
		Session.getIsBill(dAccounts, sPayIsBill)
		Session.getLatestBillDate(dAccounts, sPaySelectedDate)    	

   	switch sParent [
            case "bill" gotoBillSummary
            case "usage" gotoBillUsage
            case "document" gotoDocument
            case "payment_onetime" gotoPayment
            case "payment_automatic" gotoPayment
            case "payment_wallet" gotoPayment 
            case "payment_history" gotoPayment
            case "payment_document" gotoDocument
            default gotoBillSummary
    	]
    ]
    
    /* 12. Action to go to bill summary.*/
    action gotoBillSummary [    
    	gotoUc(billSummary)
    ]
    
    /* 12A. Action to go to bill usage.*/
    action gotoBillUsage [
    	gotoUc(billUsage)
    ] 
    
    /* 12B. Action to go to document.*/
    action gotoDocument [
    	gotoUc(document)
    ] 

	/** 12C. Action to go to payment. Payment is treated differently
	* 		from other use cases because we want to come back to the 
	*		subtab we were on after switching accounts. So the child
	* 		use case is started AFTER the sub-tab on payment is 
	* 		started becoming its 'virtual parent' even
	* 		though the real parent of the use case is the PAYMENT module
	* 		and starting use case which is payment.uc.
	*/
    action gotoPayment [
    	gotoModule(PAYMENT)[sActive:sParent]
    ] 
    
	action gotoPaymentOnetime [
		sParent = "payment_onetime"
		goto (gotoPayment)
	]    

	/*************************
	* EXTENSION SCENARIOS
	*************************/
	/** 1A. There was either no Vault document found for the bill, or more than 1 was found. In that
	 * 			case we will hide the "View pdf" link. 
	 */ 
	action hidePdfLink [
		sBillsFound = "false"
		
		goto (loadLatestBill)
	]
	
	/** 2A. There was a problem trying to get the initialize the bill data. */
	 action actionBillProblem [
		displayMessage(type: "danger" msg: msgBillError)

        goto(screenShowInfo) 
	]	
	
	/** 3A. There was a problem trying to retrieve status information. */
	action errorRetrievingStatus [
		displayMessage (type: "danger" msg: msgStatusError)
		goto(screenShowInfo)
	]
]
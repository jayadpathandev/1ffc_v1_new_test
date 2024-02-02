useCase paymentConvenienceFee [
   /**
    *  author: Rohit Singh
    *  created: 31-January-2024
    *
    *  Primary Goal:
    *       1. Get the convenienceFee for an account
    *       
    *  Alternative Outcomes:
    *       1. None 
    *                     
    *   Major Versions:
    *        
    */

    documentation [
        preConditions: [[
            1.
        ]]
        triggers: [[
            1.
        ]]
        postConditions: [[
            1. Primary -- Sends back the json succes or error response.
        ]]
    ]
    
    /* entry point of this UC file */
    startAt init
    
    /* Name of the endpoint which we will call to get the convenienceFee value  */
    shortcut getConvenienceFee(init) [
        pay_group,
	    pay_account_number
    ]

    /*************************
	* DATA ITEMS SECTION
	*************************/  
    importJava Session(com.sorrisotech.app.utils.Session)

    /* Status service goes here */
    serviceStatus srAccountStatusCode
    serviceParam (AccountStatus.GetDebitConvenienceFee) srGetDebitConvenienceFeeParams
    serviceResult (AccountStatus.GetDebitConvenienceFee) srGetDebitConvenienceFeeResult	
	
	native string user_id				= Session.getUserId()
	native string pay_group				= ""
	native string pay_account_number	= ""
	
	native string convenienceFeeAmount	= ""
	

	/*
	 * Response codes:
	 * 
	 * Success:    200 ConvenienceFee returned successfully.
	 * 
	 * Failure:    400 Invalid input. See required parameters
	 *             500 Error occurred while processing
	 * 
	 */
                     
	native string successCode       = "200"	
	native string invalidInput   	= "400"	
	native string generalError	    = "500"
	
	native string statusSuccess		= "Success"
	native string statusFailure		= "Internal server error"
	native string statusInvalid		= "Invalid input provided"
	
	native string resultCode 		= ""        
	native string httpStatus		= ""
	
        
    /*************************
	* MAIN SUCCESS SCENARIOS
	*************************/
		
	/* 1. Initialize */
	/* 1.1. Validate userId */
	action init [
		if user_id == "" then  
			validationError
	    else
	    	validatePayGroup
	]

	/* 2. Validate PayGroup */
	action validatePayGroup [
		if pay_group == "" then 
			validationError
	 	else
	 		validateAccountNumber
	]
	
	/* 3. Validate PayGroup */
	action validateAccountNumber [
		if pay_account_number == "" then 
			validationError
	 	else
	 		getConvenienceFee
	]

	/* 4.1. get convenience fee value */
    action getConvenienceFee [
		srGetDebitConvenienceFeeParams.user 		= user_id
		srGetDebitConvenienceFeeParams.paymentGroup = pay_group
		srGetDebitConvenienceFeeParams.account		= pay_account_number
		
		// getting the convenienceFee value
   		switch apiCall AccountStatus.GetDebitConvenienceFee(srGetDebitConvenienceFeeParams, srGetDebitConvenienceFeeResult, srAccountStatusCode) [
    		case apiSuccess getConvenienceFeeSuccessAudit
    		default getConvenienceFeeErrorAudit
    	]
	]	
	
	/* 5.1. audit log for success */
	action getConvenienceFeeSuccessAudit [
		resultCode = successCode
		httpStatus = statusSuccess
//		convenienceFeeAmount = srGetDebitConvenienceFeeResult.convenienceFeeAmt
		convenienceFeeAmount = "1.50"
		
    	auditLog(audit_payment.convenience_fee_success) [
			user_id
    		pay_group
    		pay_account_number 
			resultCode
			convenienceFeeAmount
    	]
    	goto (returnSuccess)
    ]
	
	/* 6.1. Json Success.*/
	json returnSuccess [	
		display resultCode
		display httpStatus
		display convenienceFeeAmount	    
	]
	
	/* 5.2. audit log for success */
	action getConvenienceFeeErrorAudit [
		resultCode = generalError
		httpStatus = statusFailure
		convenienceFeeAmount = "0"
		auditLog(audit_payment.convenience_fee_failure) [
			user_id
    		pay_group
    		pay_account_number 
			resultCode
			convenienceFeeAmount
    	]	
    	goto (returnError)
    ]		

	/* 4.2. Invalid input data  */
	action validationError [
		resultCode = invalidInput
		httpStatus = statusInvalid
		convenienceFeeAmount = "0"
    	auditLog(audit_payment.convenience_fee_invalid_input) [
    		user_id
    		pay_group
    		pay_account_number
    	]			
		goto (returnError)
	]
	
	/* 6.2 Json error.*/
	json returnError [
		display resultCode
		display httpStatus
		display convenienceFeeAmount
	]

]
	
useCase paymentHistory [
   /**
    *  author: Maybelle Johnsy Kanjirapallil
    *  created: 25-Apr-2016
    *
    *  Primary Goal:
    *       1. Display payment history.
    *       
    *  Alternative Outcomes:
    *       1. None 
    *                     
    *   Major Versions:
    *        1.0 25-Apr-2016 First Version Coded [Maybelle Johnsy Kanjirapallil]
    */

    documentation [
        preConditions: [[
            1. User is logged in.
        ]]
        triggers: [[
            1. The user clicks the sub menu option Payment History in the Payments page.
        ]]
        postConditions: [[
            1. Primary -- Payment history details are displayed.
        ]]
    ]
    actors [ 
        view_payment
    ]       
		    
    startAt init
    
    child utilImpersonationActive(utilImpersonationActive)
        
    /*************************
	* DATA ITEMS SECTION
	*************************/ 
    importJava Session(com.sorrisotech.app.utils.Session)
    importJava I18n(com.sorrisotech.app.common.utils.I18n)   
    importJava UcPaymentAction(com.sorrisotech.uc.payment.UcPaymentAction) 
    importJava LocalizedFormat(com.sorrisotech.common.LocalizedFormat)
    importJava DisplayAccountMasked(com.sorrisotech.fffc.account.DisplayAccountMasked)	
    
    import billCommon.sPayAccountInternal
    import billCommon.sPayGroup       
        
    import paymentCommon.sPmtGroupConfigResult    
    import apiPayment.pmtRequest
    import apiPayment.getScheduledPayment
    import apiPayment.deleteScheduledPayment			    	
	import apiPayment.pmtHistory	 
 
    string sLabelPaymentPosted    		= "{Payment posted}"
    string sLabelPaymentFailed    		= "{Payment failed}"
    string sCancelFuturePopinTitle    	= "{CONFIRM CANCEL PAYMENT}"  
    string sCancelFutureText3         	= "{This action cannot be undone.}"      
    string sViewDetailPayment           = "{View details}"    
    string sLabelPaymentCancel        	= "{Cancel payment}"   
    
    string sFuturePaymentHeader       	= "{Upcoming payments}"   
    string sPastPaymentHeader		  	= "{View past payments}"
  	string sPaymentDetailsPopinTitle  	= "{Payment Details}"        	
    string sSourceErrorMsg              = "{An error occurred while trying to fulfill your request. Please try again later}"
    string sPaymentSummaryHeader        = "{Payment summary}"
    string sPaymentMethodHeader         = "{Payment method}"
    string sPaymentMethodInfo           = "{Not having the total amount on your credit card on the processing date will result in additional costs.}"
    string sPaymentConfirmHeader        = "{Payment confirmed}"
    string sPaymentRequestReceivedLabel = "{PAYMENT REQUEST RECEIVED}"
    string sProcessingDateLabel         = "{ESTIMATED PROCESSING DATE}"
    string sTransactionIdLabel          = "{Transaction ID}"
    string sPaymentDateLabel		    = "{Payment Date}"
    
    static sAccountIdLabel     			= "{Account #}"
    static sAccountNumLabel     		= "{Account #}"
    static sBillNumberLabel				= "{Bill #}"
    static sPayAmountLabel	            = "{Pay amount}"
	static sPaySurchargeLabel           = "{Surcharge}"
    static sPayTotalAmountLabel         = "{Total amount}"
    static sPaymentSummerHdrSelected    = "{Payment summary - selected accounts}"
    static sAccountNum					= "{accounts}"
    static sBillNum                     = "{bills}"
    static expandedAccounts 			= "{Expand table}"
    static collapseAccounts 			= "{Collapse table}"
    string tableContent 				= "Java script failed to execute" 
    static sMultipleAccounts 			= "Multiple accounts"
    
	static type_bank    = "{BANK ACCOUNT}"
	static type_credit  = "{CREDIT CARD}"
	static type_debit   = "{DEBIT CARD}"
	static type_sepa    = "{SEPA ACCOUNT}"
	static type_unsaved = "{UNSAVED METHOD}"
	
	static unsavedBankAcct 		= "{Unsaved bank account}"
	static unsavedCreditCard 	= "{Unsaved credit card}"
	static unsavedDebitCard 	= "{Unsaved debit card}"
	static unsavedSepaAcct 		= "{Unsaved sepa account}"
	   

	static sMessageDelete   = "{Payment for <1> has been successfully removed.}"
	volatile string sSourceDeleteMsg = I18n.translate ("paymentHistory_sMessageDelete", sAccountNumber) 
	
    native string sUserId                = Session.getUserId()
    native string sAppType 			 	 = Session.getAppType()
    native string sDummy		  		 = ""
    native string sOnlineTransId      	 = ""    
    native string sAccountNumber         = ""     
    native string sAmount                = ""   
    native string sPaymentMethodNickName = "" 
    native string sPaymentDetailsName    = ""
    native string sPaymentMethodType     = "" 
	native string sPaymentMethodAccount  = "" 
	native string sTransactionID	     = ""
	native string sBillId			     = ""
	native string sPaymentAmount         = ""
	native string sPaymentSurcharge      = ""
    native string sPaymentRequestReceived  = ""
    native string sEstimatedProcessingDate = ""

    native string sScheduledDeleteMsgFlag = "false"
    native string sScheduledErrorMsgFlag  = "false"
    native string sCancelTextFinal
    
    native string nAmount
    native string sDisplayAmt = UcPaymentAction.formatAmtText(nAmount, sPayGroup, "history")
    native string sSurchargeFlag = UcPaymentAction.getSurchargeStatus()
	native string sFormat = LocalizedFormat.toJsonString()
	native string foo = ""
    
	static sCancelText1         	   = "{Are you sure you want to cancel the payment of}"    	
	static sCancelText2         	   = "{for account [b]<1>[/b]}"    	
	volatile string sCancelNewText1    = I18n.translate ("paymentHistory_sCancelText1")
	volatile string sCancelNewText2    = I18n.translate ("paymentHistory_sCancelText2", sAccountNumber)
	
	string sSurchargeClass = "hide-surcharge"    //-- By default the surcharge is disabled untill user turn it on in configuration 
		
	serviceStatus ssStatus
	
    serviceParam(Payment.GetScheduledPayment)  srGetScheduledParam
    serviceResult(Payment.GetScheduledPayment) srGetScheduledResult
        
    serviceParam(Payment.DeleteScheduledPayment)  srDeleteScheduledParam
    serviceResult(Payment.DeleteScheduledPayment) srDeleteScheduledResult
        
    serviceParam(Payment.GetHistory)  srHistoryParam
    serviceResult(Payment.GetHistory) srHistoryResult
    		
    serviceResult(DisplayConfig.GetPastPaymentsConfig) srGetResponse
    
	structure(message) msgNoPmtGroupError [
		string(title) sTitle = "{Configuration problem}"
		string(body) sBody = "{There is no payment group configured to your account. Please contact your System Administrator.}"
	]
	
    structure(message) msgMultiplePmtGroupError [
		string(title) sTitle = "{Not supported}"
		string(body) sBody = "{There are more than one payment group configured to your account. We currently do not support multiple payment groups. Please contact your System Administrator.}"
	]
		
	/* Table for upcoming payments.*/	
	table tScheduledPaymentsTable [
        emptyMsg: "{There are no upcoming payments to display}"
        
        "ONLINE_TRANS_ID"     => string sOnlineTransId          
        "BILLING_ACCOUNT_ID"  => string sAccId
        "INTERNAL_ACCOUNT_ID" => string sIntAccId  
        "DOCUMENT_NUMBER"     => string sDocumentId        
        "SOURCE_ID"   	      => string sSourceId                
        "PAY_TYPE"			  => string sPayType
        "PAY_AMT"    		  => string sPayAmount
        "PAY_AMT_NUM" 		  => number nPayAmount  
        "PAY_SURCHARGE"       => string sPaySurcharge
        "PAY_SURCHARGE"  	  => number nPaySurcharge        
        "PAY_TOTAL_AMT"       => string sPayTotalAmount
        "PAY_TOTAL_AMT"  	  => number nPayTotalAmount                     
        "PAY_DATE"      	  => string sPayDate
        "PAY_DATE_NUM"   	  => number nPayDate
        "PAY_REQ_DATE"    	  => string sPayReqDate
        "PAY_REQ_DAT_NUM" 	  => number nPayReqDate
        "EDIT_DATE"           => string sLastEditDate
        "EDIT_DATE_NUM"       => number nLastEditDate
        "SOURCE_NAME"   	  => string sSourceName
        "DETAILS_NAME"		  => string sDetailsName
        "SOURCE_TYPE"   	  => string sSourceType
        "SOURCE_NUM"   	      => string sSourceNum
        "PAY_GROUP"           => string sPayGroup
        
        link "" futurePaymentDetails(futurePaymentDetailsPopin) [          
           sOnlineTransId: sOnlineTransId             
           sPaymentMethodNickName: sSourceName
           sPaymentDetailsName: sDetailsName
           sPaymentMethodType: sSourceType
           sPaymentMethodAccount: sSourceNum
           sPaymentRequestReceived: sPayReqDate
           sEstimatedProcessingDate: sPayDate
        ]
        
        link "" futurePaymentDelete(assignText) [            
           sOnlineTransId: sOnlineTransId  
           sAccountNumber: sAccId
           sAmount: sPayAmount
           nAmount: nPayAmount
           sPayGroup: sPayGroup
        ]
                   
        column accountCol("{Pay for}") [
            elements: [sAccId]   
            sort: [sAccId]
            tags: [ "d-none", "d-md-table-cell" ]
        ]
            
        column payFromCol("{Pay from}") [
            elements: [sSourceName]                      
        ] 
 
        column dueDateCol("{Date to be processed}") [
            elements: [sPayDate]  
            sort: [nPayDate]                      
        ] 
 
 		column payTypeCol("Payment type") [
 			elements: [sPayType]
	    ]
                                  
        column payAmountCol("{Pay amount}") [
            elements: [sPayAmount]   
            tags: [ "d-none", "d-md-table-cell", "text-end" ]
        ]    
        
       column paySurchargeCol("{Surcharge}") [
            elements: [sPaySurcharge]   
            tags: ["conditional-on-surcharge", "text-end", "d-none", "d-md-table-cell", ]
        ]  
         
         column payTotalAmountCol("{Total amount}") [
            elements: [sPayTotalAmount]   
            tags: ["conditional-on-surcharge", "text-end"]
        ]  
        
        column lastEditDateCol("{Last edit}") [
            elements: [sPayReqDate]   
            sort: [nPayReqDate]
        ]        
        
        column actionsCol("{Actions}") [
           elements: [               
           		futurePaymentDetails: [
           			^type: "popin"      	
           			attr_class: "payment-history-eyeopen-img st-left-space"  
           			popin_size: "lg"   	          				
           		],
            	            	
            	futurePaymentDelete: [
           			^type: "popin"    
           			attr_class: "payment-cancel-img st-left-space"       			
           		]  
           ]
       ]                  
    ]
    
   /* History table */ 
    table tHistoryTable [
        emptyMsg: "{There are no payments to display.}"
        
        "ONLINE_TRANS_ID"     => string sOnlineTransId
        "TRANSACTION_ID"      => string sTransId 
        "BILLING_ACCOUNT_ID"  => string sAcctId
        "INTERNAL_ACCOUNT_ID" => string sIntAccId
        "DOCUMENT_NUMBER"     => string sDocumentId
        "PAY_FROM_ACCOUNT"    => string sPayFrom
        "DETAILS_NAME"	  	  => string sPaymentDetailsName
        "PAY_SOURCE_TYPE"	  => string sSourceType
        "PAY_SOURCE_NUM"	  => string sSourceNum
        "PAY_CHANNEL"         => string sPayChannel
        "PAY_DATE"            => string sPayDate
        "PAY_DATE_NUM"        => number nPayDate         
        "DUE_DATE"            => string sDueDate        
        "DUE_DATE_NUM"        => number nDueDate
        "USER_ID"             => string sUserId
        "FLEX_1"			  => string sFlexCol1
        "FLEX_2"			  => string sFlexCol2
        "FLEX_3"			  => string sFlexCol3
        "FLEX_4"			  => string sFlexCol4
        "FLEX_5"			  => string sFlexCol5
        "FLEX_6"			  => string sFlexCol6
        "FLEX_7"			  => string sFlexCol7
        "FLEX_8"			  => string sFlexCol8
        "FLEX_9"			  => string sFlexCol9
        "FLEX_10"			  => string sFlexCol10
        "FLEX_11"			  => string sFlexCol11
        "FLEX_12"			  => string sFlexCol12
        "FLEX_13"			  => string sFlexCol13
        "FLEX_14"			  => string sFlexCol14
        "FLEX_15"			  => string sFlexCol15
        "FLEX_16"			  => string sFlexCol16
        "FLEX_17"			  => string sFlexCol17
        "FLEX_18"			  => string sFlexCol18
        "FLEX_19"			  => string sFlexCol19
        "FLEX_20"			  => string sFlexCol20
        "PAY_AMT"             => string sPayAmount
        "PAY_AMT_NUM"         => number nPayAmount   
        "PAY_SURCHARGE"       => string sPaySurcharge
        "PAY_SURCHARGE"  	  => number nPaySurcharge        
        "PAY_TOTAL_AMT"       => string sPayTotalAmount
        "PAY_TOTAL_AMT"  	  => number nPayTotalAmount                     
        "PAY_STATUS"          => string sPayStatus
        
        "" => string iPayChanOnline  = "" 
        "" => string iPayChanStore   = ""   
        "" => string iPayChanPhone   = ""  
        "" => string iPayChanPartner = "" 
        "" => string iPayChanCheck   = ""  
        "" => string iPayChanMail    = ""  
        "" => string iPayChanOther   = "" 
                      
        "" => string  sPayChanOnline  = "Online" 
        "" => string  sPayChanStore   = "Store"   
        "" => string  sPayChanPhone   = "Phone"
        "" => string  sPayChanPartner = "Partner"
        "" => string  sPayChanCheck   = "Check" 
        "" => string  sPayChanMail    = "Mail"
        "" => string  sPayChanOther   = "Other"
        
        "" => string iPayStatusPosted = ""
        "" => string iPayStatusFailed = ""
        "" => string iPayStatusProcessing = ""
        
        "" => string  sPayStatusPosted = "Posted"
        "" => string  sPayStatusProcessing = "Processing"  
        "" => string  sPayStatusFailed = "Failed"   
        
        link "" pastPaymentDetails(pastPaymentDetailsPopin) [  
           sOnlineTransId: sOnlineTransId 
           sTransactionID : sTransId      
           sPaymentMethodNickName: sPayFrom
           sPaymentDetailsName: sPaymentDetailsName
           sPaymentMethodType: sSourceType
           sPaymentMethodAccount: sSourceNum           
           sEstimatedProcessingDate: sPayDate
        ]           

        column documentCol("{Paid for}") [
            elements: [sAcctId]  
            sort: [sAcctId]
            tags: [ "visually-hidden" ]
        ] 
             
        column transactionIdCol("{Transaction ID}") [
            elements: [sTransId]   
            sort: [sTransId]
            tags: [ "d-none", "d-md-table-cell", "visually-hidden" ]
        ]

        column payFromCol("{Paid from}") [
            elements: [sPayFrom]  
            tags: [ "d-none", "d-md-table-cell", "visually-hidden" ]
        ] 
 
         column dueDateCol("{Date processed}") [
            elements: [sPayDate]  
            sort: [nPayDate]
            tags: [ "visually-hidden" ]            
        ] 
                      
		column payChannelCol("Payment channel") [
		 	tags: ["payment-history-channel", "d-none", "d-md-table-cell", "visually-hidden"]
		    elements: [
		        iPayChanOnline: [
		            ^class: 'pay-chan-online st-payment-channel-icon'
		            ^class: sPayChannel
		        ]
		        iPayChanStore: [
		            ^class: 'pay-chan-store st-payment-channel-icon'
		            ^class: sPayChannel
		        ]
		        iPayChanPhone: [
		            ^class: 'pay-chan-phone st-payment-channel-icon'
		            ^class: sPayChannel
		        ]
		        iPayChanPartner: [
		            ^class: 'pay-chan-partner st-payment-channel-icon'
		            ^class: sPayChannel
		        ]
		        iPayChanCheck: [
		            ^class: 'pay-chan-check st-payment-channel-icon'
		            ^class: sPayChannel
		        ]
		        iPayChanMail: [
		            ^class: 'pay-chan-mail st-payment-channel-icon'
		            ^class: sPayChannel
		        ]
		        iPayChanOther: [
		            ^class: 'pay-chan-other st-payment-channel-icon'
		            ^class: sPayChannel
		        ]		        
		        sPayChanOnline: [
		            ^class: 'pay-chan-online'
		            ^class: sPayChannel
		        ]
		        sPayChanStore: [
		            ^class: 'pay-chan-store'
		            ^class: sPayChannel
		        ] 
		        sPayChanPhone: [
		            ^class: 'pay-chan-phone'
		            ^class: sPayChannel
		        ]
		        sPayChanPartner: [
		            ^class: 'pay-chan-partner'
		            ^class: sPayChannel
		        ]
		        sPayChanCheck: [
		            ^class: 'pay-chan-check'
		            ^class: sPayChannel
		        ]
		        sPayChanMail: [
		            ^class: 'pay-chan-mail'
		            ^class: sPayChannel
		        ]
		        sPayChanOther: [
		            ^class: 'pay-chan-other'
		            ^class: sPayChannel
		        ]		        
		    ]
		]
                      
         column flex1Col("{Flex 1}") [
            elements: [sFlexCol1]  
            sort: [sFlexCol1]
            tags: [ "d-none", "d-md-table-cell", "visually-hidden" ]
        ] 
 
         column flex2Col("{Flex 2}") [
            elements: [sFlexCol2]  
            sort: [sFlexCol2]
            tags: [ "d-none", "d-md-table-cell", "visually-hidden" ]
        ] 
 
         column flex3Col("{Flex 3}") [
            elements: [sFlexCol3]  
            sort: [sFlexCol3]
            tags: [ "d-none", "d-md-table-cell", "visually-hidden" ]
        ] 
 
         column flex4Col("{Flex 4}") [
            elements: [sFlexCol4]  
            sort: [sFlexCol4]
            tags: [ "d-none", "d-md-table-cell", "visually-hidden" ]
        ] 
 
         column flex5Col("{Flex 5}") [
            elements: [sFlexCol5]  
            sort: [sFlexCol5]
            tags: [ "d-none", "d-md-table-cell", "visually-hidden" ]
        ] 
 
         column flex6Col("{Flex 6}") [
            elements: [sFlexCol6]  
            sort: [sFlexCol6]
            tags: [ "d-none", "d-md-table-cell", "visually-hidden" ]
        ] 
 
         column flex7Col("{Flex 7}") [
            elements: [sFlexCol7]  
            sort: [sFlexCol7]
            tags: [ "d-none", "d-md-table-cell", "visually-hidden" ]
        ] 
 
         column flex8Col("{Flex 8}") [
            elements: [sFlexCol8]  
            sort: [sFlexCol8]
            tags: [ "d-none", "d-md-table-cell", "visually-hidden" ]
        ] 
 
         column flex9Col("{Flex 9}") [
            elements: [sFlexCol9]  
            sort: [sFlexCol9]
            tags: [ "d-none", "d-md-table-cell", "visually-hidden" ]
        ] 
 
         column flex10Col("{Flex 10}") [
            elements: [sFlexCol10]  
            sort: [sFlexCol10]
            tags: [ "d-none", "d-md-table-cell", "visually-hidden" ]
        ] 
 
         column flex11Col("{Flex 11}") [
            elements: [sFlexCol11]  
            sort: [sFlexCol11]
            tags: [ "d-none", "d-md-table-cell", "visually-hidden" ]
        ] 
 
         column flex12Col("{Flex 12}") [
            elements: [sFlexCol12]  
            sort: [sFlexCol12]
            tags: [ "d-none", "d-md-table-cell", "visually-hidden" ]
        ] 
 
         column flex13Col("{Flex 13}") [
            elements: [sFlexCol13]  
            sort: [sFlexCol13]
            tags: [ "d-none", "d-md-table-cell", "visually-hidden" ]
        ] 
 
         column flex14Col("{Flex 14}") [
            elements: [sFlexCol14]  
            sort: [sFlexCol14]
            tags: [ "d-none", "d-md-table-cell", "visually-hidden" ]
        ] 
 
         column flex15Col("{Flex 15}") [
            elements: [sFlexCol15]  
            sort: [sFlexCol15]
            tags: [ "d-none", "d-md-table-cell", "visually-hidden" ]
        ] 
 
         column flex16Col("{Flex 16}") [
            elements: [sFlexCol16]  
            sort: [sFlexCol16]
            tags: [ "d-none", "d-md-table-cell", "visually-hidden" ]
        ] 
 
         column flex17Col("{Flex 17}") [
            elements: [sFlexCol17]  
            sort: [sFlexCol17]
            tags: [ "d-none", "d-md-table-cell", "visually-hidden" ]
        ] 
 
         column flex18Col("{Flex 18}") [
            elements: [sFlexCol18]  
            sort: [sFlexCol18]
            tags: [ "d-none", "d-md-table-cell", "visually-hidden" ]
        ] 
 
         column flex19Col("{Flex 19}") [
            elements: [sFlexCol19]  
            sort: [sFlexCol19]
            tags: [ "d-none", "d-md-table-cell", "visually-hidden" ]
        ] 
 
         column flex20Col("{Flex 20}") [
            elements: [sFlexCol20]  
            sort: [sFlexCol20]
            tags: [ "d-none", "d-md-table-cell", "visually-hidden" ]
        ] 

        column payAmountCol("{Pay amount}") [
            elements: [sPayAmount]   
            tags: ["text-end", "d-none", "d-md-table-cell", "visually-hidden"]          
        ]  
        
        column paySurchargeCol("{Surcharge}") [
            elements: [sPaySurcharge]   
            tags: ["conditional-on-surcharge", "text-end", "d-none", "d-md-table-cell", "visually-hidden"]
        ]  
         
         column payTotalAmountCol("{Total amount}") [
            elements: [sPayTotalAmount]   
            tags: ["conditional-on-surcharge","text-end", "visually-hidden"]
        ]  
         
        column statusCol("{Status}") [
        	tags: ["payment-history-status" ]
   			elements: [
        		iPayStatusPosted: [
            		^class: 'pay-status-posted st-payment-status-icon'
            		^class: sPayStatus
        		]
        		iPayStatusProcessing: [
            		^class: 'pay-status-processing st-payment-status-icon'
            		^class: sPayStatus
        		]
        		iPayStatusFailed: [
            		^class: 'pay-status-failed st-payment-status-icon'
            		^class: sPayStatus
        		]  
        		sPayStatusPosted: [
            		^class: 'pay-status-posted'
            		^class: sPayStatus
        		]
        		sPayStatusProcessing: [
            		^class: 'pay-status-processing'
            		^class: sPayStatus
        		]
        		sPayStatusFailed: [
            		^class: 'pay-status-failed'
            		^class: sPayStatus
        		]
     		]            
        ]     
 
        column actionsCol("{Actions}") [
           elements: [               
           		pastPaymentDetails: [
           			^type: "popin"      
           			attr_class: "payment-history-eyeopen-img st-left-space"     		
           			popin_size: "lg"	
           		]            	            	
           ]
       ]                
                   
    ]
 
     
   /*************************
	* MAIN SUCCESS SCENARIOS
	*************************/
	
	/* 1. Get the most recent docs. */
	action init [				
		if sSurchargeFlag == "true"	then 
		   	setSurchargeClass
		else 		
			getScheduledPayment
    ]
    
    /*-- set the surchargeClass variable to show or hide if surcharge is enabled or not --*/
    action setSurchargeClass [
    	sSurchargeClass = ""
    	goto(getScheduledPayment)

    ]
		
	/* 2. Get scheduled payment details. */
	action getScheduledPayment [		
	   	switch sAppType [        
		    case "b2c"  getScheduledPaymentB2C
	        case "b2b"  getScheduledPaymentB2B  
	        default getScheduledPaymentB2C
	    ] 		
    ]
    
	action getScheduledPaymentB2C [		
		srGetScheduledParam.USER_ID     = sUserId
		srGetScheduledParam.FORMAT_JSON = sFormat
		srGetScheduledParam.ACCOUNT     = sPayAccountInternal
		srGetScheduledParam.PAY_GROUP   = sPayGroup	
		
		switch apiCall Payment.GetScheduledPayment(srGetScheduledParam, srGetScheduledResult, ssStatus) [
		    case apiSuccess getScheduledResults
		    default paymentStatusScreen
		]
    ] 
    
    action getScheduledPaymentB2B [		
		srGetScheduledParam.USER_ID     = sUserId
		srGetScheduledParam.FORMAT_JSON = sFormat
		
		switch apiCall Payment.GetScheduledPayment(srGetScheduledParam, srGetScheduledResult, ssStatus) [
		    case apiSuccess getScheduledResults
		    default paymentStatusScreen
		]
    ]
    
    /* 3. Populate the scheduled payments table. */
	action getScheduledResults [
        DisplayAccountMasked.setAccountDataTableFromPaymentDataMaskedAccount(srGetScheduledResult.schedule, tScheduledPaymentsTable)      
        goto(getHistory)   
    ]
    
    /* 4. Get payment history details. */
	action getHistory [		
	   	switch sAppType [        
		    case "b2c"  getHistoryB2C
	        case "b2b"  getHistoryB2B  
	        default getHistoryB2C
	    ] 		
    ]
    
	action getHistoryB2C [
		srHistoryParam.USER_ID     = sUserId
		srHistoryParam.FORMAT_JSON = sFormat
		srHistoryParam.ACCOUNT     = sPayAccountInternal
		srHistoryParam.PAY_GROUP   = sPayGroup		
				
		switch apiCall Payment.GetHistory(srHistoryParam, srHistoryResult, ssStatus) [
		    case apiSuccess getHistoryConfig
		    default paymentStatusScreen
		]
    ]
    
    action getHistoryB2B [
		srHistoryParam.USER_ID     = sUserId
		srHistoryParam.FORMAT_JSON = sFormat
				
		switch apiCall Payment.GetHistory(srHistoryParam, srHistoryResult, ssStatus) [
		    case apiSuccess getHistoryConfig
		    default paymentStatusScreen
		]
    ]
    
    action getHistoryConfig [
		switch apiCall DisplayConfig.GetPastPaymentsConfig(srGetResponse, ssStatus) [
		    case apiSuccess getHistoryResults
		    default paymentStatusScreen
		]
    	
    ]
    
    /* 5. Populate the payments history table. */
    action getHistoryResults [  
        DisplayAccountMasked.setAccountDataTableFromPaymentHistoryDataMaskedAccount(srHistoryResult.history, tHistoryTable, srGetResponse.RSP_CONFIG)      
        goto(paymentStatusScreen)   
    ]
    
    /* 6. Shows the payment history details. */
    xsltScreen paymentStatusScreen("{Payment}") [

		child utilImpersonationActive		
		  
		div message1 [
			logic: [						
				if sPmtGroupConfigResult != "nopaygroup" then "hide"						
			]				
			class: "alert alert-danger"
			attr_role: "alert"				
			display msgNoPmtGroupError 
		]
		
		div message2 [
			logic: [						
				if sPmtGroupConfigResult != "manypaygroups" then "hide"						
			]				
			class: "alert alert-danger"
			attr_role: "alert"				
			display msgMultiplePmtGroupError 
		]
					
	    div paymentStatus [
	      	
	      	logic: [
				if sPmtGroupConfigResult == "nopaygroup" then "remove"
				if sPmtGroupConfigResult == "manypaygroups" then "remove"														
			]
			
		  	div FuturePaymentBlock [
				class: "st-padding-top st-padding-bottom"

				// Display Header of the table
    	    	h4 futurePaymentHeader [
					class: "col-md-6"
					display sFuturePaymentHeader 
				]
					
    	    	div messagesCol [	    
    	    		class: "col-md-6"
    	    		
    	    		div sourceCreateMsg	[
	    	    		logic: [
							if sScheduledDeleteMsgFlag == "false" then "remove"						
						]
						class: "st-payment-success float-end"
    	    			
		    	    	display sSourceDeleteMsg [
							class: "st-padding-top"
						]
					]
					
    	    		div sourceErrorMsg	[
	    	    		logic: [
							if sScheduledErrorMsgFlag == "false" then "remove"						
						]
						class: "st-payment-error float-end"
    	    			
		    	    	display sSourceErrorMsg [
							class: "st-padding-top"
						]
					]
				]	
	    	    		    	    
				// Display Future payment table
				div futurepaymentsTable [   
					class: "col-md-12"
					display tScheduledPaymentsTable [
						class:sSurchargeClass
					]
				]		
				
				// Display future payment actions icons
				div futurePaymentActionIcons [
					class: "col-md-12 st-padding-top st-padding-bottom"
					
					div futurePaymentActionIconsRow [
						class: "row st-payment-help-icons"
						
						div futurepmteditIconCol [
							class: "col-6 col-sm-5 text-end"
							
							div viewDetailIcon [
								class: "st-payment-view-details-eye"								
								display sViewDetailPayment
							]
						]
						
						div futurepmtMiddleCol [
							class: "col-sm-2 d-none d-md-table-cell"	
							display sDummy
						]
						
						div futurepmtcancelIconCol [
							class: "col-6 col-sm-5 text-start"
							
							div cancelIcon [
								class: "st-payment-cancel-details"								
								display sLabelPaymentCancel
							]
						]
					]   
				]  
			]
				

		  	div PastPaymentBlock [
				class: "st-padding-top st-padding-bottom"

				// Display payment history header
				div pastPaymentHeaderRow [
	    	    	class: "col-md-12 st-padding-bottom"
	    	    	
	    	    	h4 pastPaymentHeader [
						class: "col-md-6"
						display sPastPaymentHeader 
					]	    	    	
	    	    ]	   	    				
														            			
				// Display past payment history table
				div historyTable [
					class: "col-md-12"
					display tHistoryTable[
						class:sSurchargeClass
					]		
				] 	
				
				// Display past payment history icons
				div paymentStatusIcons [
					class: "col-md-12 st-padding-top st-padding-bottom"
					
					div paymentStatusIconsRow [
						class: "row st-payment-help-icons"
						
						div paymentPostedIconCol [
							class: "col-6 col-sm-5 text-end"
							
							div paymentPostedIcon [
								class: "st-payment-posted"
								display sLabelPaymentPosted 
							]
						]
						
						div paymentMiddleCol [
							class: "col-sm-2 d-none d-md-table-cell"	
							display sDummy
						]
						
						div paymentFailedIconCol [
							class: "col-6 col-sm-5 text-start"
								
							div paymentFailedIcon [
								class: "st-payment-failed"
								display sLabelPaymentFailed 
							]
						]
					]	  
				]											
			]
									                 	                          
	      ]	  	    
	]
	
   /* 7. Recurring payment details popin.*/
    xsltFragment futurePaymentDetailsPopin [
        
        form content [
        	class: "modal-content"
        
	        div paymentDetailsHeading [
	            class: "modal-header st-border-bottom"
	            
	            div paymentDetailsHeadingRow [
	            	class: "row text-center"
	            	
	            	h4 paymentDetailsHeadingCol [
						class: "col-md-12"
						display sPaymentDetailsPopinTitle 
					]
				]
	        ]
	        
	        div body [
	        	class: "modal-body"

		    	div paymentSummary [
			    	class: "st-border-bottom"
			    			    		
					div paymentSummaryContent [
						class: "row"
		
						display tableContent [
							attr_sorriso: "element-payment-status-table" 
							attr_onlineTransId: sOnlineTransId		    								
						]
		           ]
		        ]
		        
		        div paymentMethod [
		    		class: "st-border-bottom"
		    		
			    	div paymentMethodHeaderRow [
			    		class: "row"
			    		
						h4 paymentMethodHeaderCol [
							class: "col-md-12"
							display sPaymentMethodHeader 
						]
					]
		    						
					div paymentMethodSelection [
						class: "row"
						
						h5 paymentMethodNickName [
							class: "col-md-4"
							
							display sPaymentDetailsName [
								class: "st-payment-method-nickname"
							]
						]
											
						div paymentMethodDetails [
							class: "col-md-8"
							
							div paymentMethodTypeRow [
								class: "row"
							
								div paymentMethodTypeCol [
									class: "col-md-12"
									
									display sPaymentMethodType [
										class: "st-payment-method-type"
									]
									
									div paymentMethodTypeCredit [
										class: "st-payment-credit-card"
					            		logic: [
											if sPaymentMethodType != "CREDIT CARD" then "remove"						
										]
										display sDummy
					        		]
					        		
					        		div paymentMethodTypeDebit [
					        			class: "st-payment-debit-card"
					            		logic: [
											if sPaymentMethodType != "DEBIT CARD" then "remove"						
										]
										display sDummy
					        		]
					        		
					        		div paymentMethodTypeBank [
					        			class: "st-payment-bank-account"
					            		logic: [
											if sPaymentMethodType != "BANK ACCOUNT" then "remove"						
										]
										display sDummy
					        		]
					        		div paymentMethodTypeSepa [
					        			class: "st-payment-sepa-account"
					            		logic: [
											if sPaymentMethodType != "SEPA ACCOUNT" then "remove"						
										]
										display sDummy
					        		]					        		
								]
							]
							
							div paymentMethodAccountRow [
								class: "row"
							
								div paymentMethodAccountCol [
									class: "col-md-12"
									
									display sPaymentMethodAccount [
										class: "st-payment-method-account"
									]
								]
							]
						]					
					]
				]
				
		        div paymentConfirm [
			    	class: "st-border-bottom"
			    		
			    	div paymentConfirmHeaderRow [
			    		class: "row"
			    		
						h4 paymentConfirmHeaderCol [
							class: "col-md-12"
							display sPaymentConfirmHeader 
						]
					]		    		
			    	
			    	div paymentConfirmDatesContent [
			    		class: "row"
			    		
			    		div paymentConfirmDatesContentCol1 [
			    			class: "col-md-6"
			    		
							div paymentConfirmDatesLabelRow [
								class: "row"
								
								div paymentConfirmDatesLabel [
									class: "col-md-12"
									display sPaymentRequestReceivedLabel
								]
							]
		
							div requestDateRow [
								class: "row"
								
								h4 requestDate [
									class: "col-md-12"
									display sPaymentRequestReceived
								]
							]
				    	]
				    	
			    		div paymentConfirmDatesContentCol2 [
			    			class: "col-md-6"
			    			
							div processingDateLabelRow [
								class: "row"
								
								div processingDateLabel [
									class: "col-md-12"
									display sProcessingDateLabel
								]
							]
							
							div estimatedDateRow [
								class: "row"
								
								h4 estimatedDate [
									class: "col-md-12"
									display sEstimatedProcessingDate
								]
							]
		    			]
			    	]			
		        ]
			]
				            
            div paymentDetailsButtonsRow [
            	class: "row text-center modal-footer"
            	
            	div paymentDetailsButton [
            		class: "col-md-12"
           
	                navigation closePaymentDetailsButton (paymentStatusScreen, "{CLOSE}") [  
	                    class: "btn btn-primary"		                   
	                    type: "cancel"
	                    attr_tabindex: "10"
	                ]		                
				]
			]            
        ]
	]
    
    xsltFragment pastPaymentDetailsPopin [
        
        form content [
        	class: "modal-content"
        	
	        div pastPaymentDetailsHeading [
	            class: "modal-header st-border-bottom"
	            
	            div pastPaymentDetailsHeadingRow [
	            	class: "row text-center"
	            	
	            	h4 pastPaymentDetailsHeadingCol [
						class: "col-md-12"
						display sPaymentDetailsPopinTitle 
					]
				]
	        ]
	        div body [
	        	class: "modal-body"

	        	div pastPaymentSummary [
			    	class: "st-border-bottom"
			    			    		
					div pastPaymentSummaryContent [
						class: "row"
						
						display tableContent [
							attr_sorriso: "element-payment-status-table" 
							attr_onlineTransId: sOnlineTransId		    								
						]
					]
		        ]
		        
		        div pastPaymentMethod [
	        		class: "st-border-bottom"
	        		
			    	div paymentMethodHeaderRow [
			    		class: "row"
			    		
						h4 paymentMethodHeaderCol [
							class: "col-md-12"
							display sPaymentMethodHeader 
						]
					]
	        						
					div paymentMethodSelection [
						class: "row"
						
						h5 paymentMethodNickName [
							class: "col-md-4"
							
							display sPaymentDetailsName [
								class: "st-payment-method-nickname"
							]
						]
												
						div paymentMethodDetails [
							class: "col-md-8"
							
							div paymentMethodTypeRow [
								class: "row"
							
								div paymentMethodTypeCol [
									class: "col-md-12"
									
									display sPaymentMethodType [
										class: "st-payment-method-type"
									]
									
									div paymentMethodTypeCredit [
										class: "st-payment-credit-card"
					            		logic: [
											if sPaymentMethodType != "CREDIT CARD" then "remove"						
										]
										display sDummy
					        		]
					        		
					        		div paymentMethodTypeDebit [
					        			class: "st-payment-debit-card"
					            		logic: [
											if sPaymentMethodType != "DEBIT CARD" then "remove"						
										]
										display sDummy
					        		]
					        		
					        		div paymentMethodTypeBank [
					        			class: "st-payment-bank-account"
					            		logic: [
											if sPaymentMethodType != "BANK ACCOUNT" then "remove"						
										]
										display sDummy
					        		]
					        		
					        		div paymentMethodTypeSepa [
					        			class: "st-payment-sepa-account"
					            		logic: [
											if sPaymentMethodType != "SEPA ACCOUNT" then "remove"						
										]
										display sDummy
					        		]
					        		
								]
							]
							
							div paymentMethodAccountRow [
								class: "row"
							
								div paymentMethodAccountCol [
									class: "col-md-12"
									
									display sPaymentMethodAccount [
										class: "st-payment-method-account"
									]
								]
							]
						] 	
										
					]
				]
				
		        div pastPaymentConfirm [
			    		
			    	div paymentConfirmHeaderRow [
			    		class: "row"
			    		
						h4 paymentConfirmHeaderCol [
							class: "col-md-12"
							display sPaymentConfirmHeader 
						]
					]		    		
			    	
			    	div paymentConfirmDatesContent [
			    		class: "row"
			    		
			    		div paymentConfirmDatesContentCol1 [
			    			class: "col-md-6"
			    		
							div paymentConfirmDatesLabelRow [
								class: "row"
								
								div paymentTransactionIDLabel [
									class: "col-md-12"
									display sTransactionIdLabel
								]
							]
	
							div requestDateRow [
								class: "row"
								
								h4 pastTransID [
									class: "col-md-12"
									display sTransactionID
								]
							]
				    	]
				    	
			    		div paymentConfirmDatesContentCol2 [
			    			class: "col-md-6"
			    			
							div processingDateLabelRow [
								class: "row"
								
								div paymentDateLabel [
									class: "col-md-12"
									display sPaymentDateLabel
								]
							]
							
							div pastPayDateRow [
								class: "row"
								
								h4 pastPaymentDate [
									class: "col-md-12"
									display sEstimatedProcessingDate
								]
							]
		    			]
			    	]			
		        ]
			]
				        
	        div pastPaymentDetailsButtonsRow [
            	class: "row text-center modal-footer"
            	
            	div pastPaymentDetailsButton [
            		class: "col-md-12"
           
	                navigation closePastPaymentDetailsButton (paymentStatusScreen, "{CLOSE}") [  
	                    class: "btn btn-primary"		                   
	                    type: "cancel"
	                    attr_tabindex: "10"
	                ]		                
				]
			]          
        ]
    ]   	    

	/* 8. Delete scheduled payment. */	
	action assignText [
		sCancelTextFinal = sCancelNewText1 + sDisplayAmt + sCancelNewText2	    
		goto(cancelFuturePopin)	
    ]
    
    /* 9. Future payment Cancel popin.*/    
    xsltFragment cancelFuturePopin [
        
        form content [
        	class: "modal-content"
        
	        div cancelFutureHeading [
	            class: "modal-header"
	            
	            div cancelFutureRow [
	            	class: "row text-center"
	            	
	            	h4 cancelFutureCol [
	            		class: "col-md-12"
	            		
			            display sCancelFuturePopinTitle 
					]
				]
	        ]
	        
            div cancelFutureBody [
               class: "modal-body"
               messages: "top"
                                   
                div cancelFutureRow [                	
                    class: "row text-center"
                   	                
                    display sCancelTextFinal [
                    	class: "col-md-12"    
                    ]
                    display sCancelFutureText3 [
                    	class: "col-md-12 text-danger"    
                    ]																					
				]                
            ]
                       
            div cancelFutureButtons [
                class: "modal-footer"

    			navigation yesFutureButton (deleteScheduledPayment, "{YES}") [  
                	class: "btn btn-primary"
                	attr_tabindex: "10"		                   		                                    
            	]
            	
    			navigation noFutureButton (paymentStatusScreen, "{NO}") [   
    				attr_tabindex: "11"
    			]
            ]
        ]        
    ]
    
	/* 10. Delete scheduled payment. */	
	action deleteScheduledPayment [
			    
		srDeleteScheduledParam.ONLINE_TRANS_ID = sOnlineTransId
	    
		switch apiCall Payment.DeleteScheduledPayment(srDeleteScheduledParam, srDeleteScheduledResult, ssStatus) [
            case apiSuccess checkDeleteResult
            default genericErrorMsg
        ]	
    ]
    
    /* 11. Check delete scheduled payment result. */
	action checkDeleteResult [		
		if srDeleteScheduledResult.RESULT == "success" then
    		setScheduledDeleteMsgFlag
    	else 
    		genericErrorMsg	
	]
	
	/* 12. Sets delete scheduled payment success flag to true. */
	action 	setScheduledDeleteMsgFlag [
		sScheduledErrorMsgFlag  = "false"		
		sScheduledDeleteMsgFlag = "true"
		
		goto(init)
	]    	    
	
	/* 13. Generic error message. */
	action genericErrorMsg [		
		sScheduledErrorMsgFlag  = "true"
		sScheduledDeleteMsgFlag = "false"
		
        goto(paymentStatusScreen)
	]	    
]  
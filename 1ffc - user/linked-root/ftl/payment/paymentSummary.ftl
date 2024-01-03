
<#-- 
	   File: paymentSummary.ftl
	   Date: September 11, 2023
	   Updated by: John A. Kowalonek
	   Purpose: summary freemarker template for 1st Franklin application
	   
	   2023-Sep-11	jak-- first major iteration, handles all the messages we can
	   						think of today.. unit tested without all the use case data
	   						but with 1st Franklin styled bill data. 
	   2023-Oct-24	jak-- update for new flex field settings.
	   
	   2023-Dec-11	jak-- simplified based on separating out new, closed, and view disabled
	   						accounts into a different template.
	   2024-Jan-02  jak-- bug fixes for 1st Franklin based on moving data around.

  -->

<#--  "date_format" -- setting the date format here for just this template... was having a problem with the date 
		handed down from the use case so using bill.dueDate instead of the dueDate stuffed into
		the variables directly. There was some kind of locale problem with my setup (I'm guessing) 
		because all dueDate had curly braces around it.
		
	   "debug" -- if true will show the status and scheduled payment stuff on the screen for visual validation
	   	 of the settings -->
	   	 
<#setting date_format="MM/dd/yyyy">
<#assign debug = false>


<#--  Test to ensure all the status stuff came down ok.. its "belt and suspenders" this was already
		done at the use case level but one more time will prevent user seeing something stupid if
		bad stuff happened we need to convert second level variables to first level so we can write 
		to them (this is a limitation of freemarker, you can't change "second level" variable, just
		read them -->

<#assign accountStatus = "unknown">
<#assign paymentEnabled = "unknown">
<#assign achEnabled = "unknown">
<#assign viewAccount = "unknown">

<#if status.accountStatus?has_content>
	<#assign accountStatus = status.accountStatus>
</#if>
<#if status.paymentEnabled?has_content>
	<#assign paymentEnabled = status.paymentEnabled>
</#if>
<#if status.achEnabled?has_content>
	<#assign achEnabled = status.achEnabled>
</#if>
<#if !status.viewAccount?has_content>
	<#assign viewAccount = status.viewAccount>
</#if>


<#-- disabling payment is a "little bit" complicated at 1st Franklin, but when you boil it down, there's only
	 	a couple of reasons that matter. Let's sort that out. organizing status.paymentEnabled -->

<#--  ** ELEMENTS FOR SCHEDULED AND AUTOMATIC PAYMENT MESSAGES ** passed in to the template by use case -->

<#-- the last schedule payment date for all one time scheduled payments before due date-->
<#assign dScheduledPaymentDate = scheduledPayment.oneTimePmtDate?date>

<#-- the total amount of all scheduled payments -->				
<#assign nScheduledPaymentAmount = scheduledPayment.oneTimePmtTotalAmt>

<#-- date of the last (and probably only) automatic payment -->
<#assign dAutomaticPaymentDate = scheduledPayment.automaticPmtDate?date>	

<#--  total amount of all (and probably only automatic payment -->	
<#assign nAutomaticPaymentAmount = scheduledPayment.automaticPmtTotalAmt>

<#-- true if the total of all scheduled payments before payment due date + the automatic payment won't work -->

<#if scheduledPayment.scheduledPmtTotalAmt?number < amount?number > 
	<#assign bScheduledPaymentsLate = true> 
<#else>
	<#assign bScheduledPaymentsLate = false>					
</#if>						


<#--  ********************************************************************************************
	  END - Settings for testing that should come from use case 
	  ******************************************************************************************** -->
	  
<#--   ** VARIABLES THAT CONTROL STATEMENT MESSAGE BEHAVIOR ..

	   This odd conversion of .now to a string with date format and then back to a date 
		allowS us to compare our "pure" date formatted dueDate when other mathmatical forms do
		not. So yeah... if for some reason, .now can't convert to a comparison string directly.. same date but keeps time.

		The test returns 0(false) if due date is is today or in the future, 1(true) if we are passed the due date -->
<#assign bPastDueDate = bill.dueDate?date < .now?string["MM/dd/yyyy"]?date />
<#assign bBillHasOverdue = bill.isBillOverdue>

	

<#--  ** bill.amountDue is the current amount due at the time of this statement. This will
		 change to something else when we implement payment history tracking -->
<#if bill.amountDue?has_content && bill.amountDue?string?trim != "">
	<#assign nAmountDue = bill.amountDue>
 	<#if bBillHasOverdue == true && bill.minDue?has_content && bill.minDue?string?trim != "">
		<#assign nAmountOverdue = bill.amountDue - bill.minDue>
	<#else>
		<#assign nAmountOverdue = "0">
	</#if>
<#else>
	<#assign nAmountDue = '0'> 	
</#if>

<#--  ** bill.dueDate is the due date for this bill -->
<#assign dDueDate = bill.dueDate?date>		<#--  we use this everywhere so make it a variable -->

<#--  ** bill.amount is the current bill amount which is the principal remaining at time of statement -->
<#if bill.amount?has_content && bill.amount?string?trim != ''>  <#-- checks to see if loan amount exists -->
	<#assign nLoanAmount = bill.amount>
<#else>
	<#assign nLoanAmount = "0">
</#if>

<#-- ***************************** LET THE GAMES BEGIN ******************************************** -->

<div class="st-payment-summary border border-5 rounded-3 border-primary p-3 mb-3">
		<#if debug> <#--  shows extra varaibles if true -->
	 <table class="table">
	  <thead>
	  	<th scope="col">Item</th>
	  	<th scopy="col">Value</th>
	  </thead>
	  <tbody>
	  	<tr>
	  		<td><span class="fw-bold">Account Status:</span></td>
	  		<td><span class="fw-bold">${accountStatus}</span></td>
	  	</tr>
		<tr>
			<td><span class="fw-bold">Payment Status:</span></td>
			<td><span class="fw-bold">${status.paymentEnabled}</span></td>
		</tr>
		<tr>
			<td><span class="fw-bold">ACH Enabled:</span></td>
			<td><span class="fw-bold">${status.achEnabled}</span></td>
		</tr>
		<tr>
			<td><span class="fw-bold">View Account:</span></td>
			<td><span class="fw-bold">${status.viewAccount}</span></td>
		</tr>
		<tr>
			<td><span class="fw-bold"># One Time Payments:</span></td>
			<td><span class="fw-bold">${scheduledPayment.oneTimePmtCount}</span></td>
		</tr>
		<tr>
			<td><span class="fw-bold">One Time Payment Date:</span></td>
			<td><span class="fw-bold">${(scheduledPayment.oneTimePmtDate?number)?number_to_date}</span></td>
		</tr>
		<tr>
			<td><span class="fw-bold">Total Value One Time Payments:</span></td>
			<td><span class="fw-bold">${formatUtils.formatAmount(scheduledPayment.oneTimePmtTotalAmt?number)}</span></td>
		</tr>
		<tr>
			<td><span class="fw-bold"># Automatic Payments:</span></td>
			<td><span class="fw-bold">${scheduledPayment.automaticPmtCount}</span></td>
		</tr>
		<tr>
			<td><span class="fw-bold">Automatic Payment Date:</span></td>
			<td><span class="fw-bold">${(scheduledPayment.automaticPmtDate?number)?number_to_date}</span></td>
		</tr>
		<tr>
			<td><span class="fw-bold">Total Value One Time Payments:</span></td>
			<td><span class="fw-bold">${formatUtils.formatAmount(scheduledPayment.automaticPmtTotalAmt?number)}</span></td>
		</tr>
		<tr>
			<td><span class="fw-bold">Total Value All Payments:</span></td>
			<td><span class="fw-bold">${formatUtils.formatAmount(scheduledPayment.scheduledPmtTotalAmt?number)}</span></td>
		</tr>
		<tr>
			<td><span class="fw-bold">Statement Amount Due:</span></td>
			<td><span class="fw-bold">${formatUtils.formatAmount(nLoanBalance)}</span></td>
		</tr>
		<tr>
			<td><span class="fw-bold">Current Amount Due:</span></td>
			<td><span class="fw-bold">${formatUtils.formatAmount(nAmountDue)}</span></td>
		</tr>
		<tr>
			<td><span class="fw-bold">Due Date:</span></td>
			<td><span class="fw-bold">${bill.dueDate?date}</span></td>
		</tr>
		<tr>
			<td><span class="fw-bold">Original Loan Amount:</span></td>
			<td><span class="fw-bold">${bill.flex9?number}</span></td>
		</tr>
		<tr>
			<td><span class="fw-bold">Statement Principal Balance:</span></td>
			<#if nLoanAmount??>
			<td><span class="fw-bold">${nLoanBalance}</span></td>
			<#else>
			<td><span class="fw-bold">not avail</span></td>
			</#if>
		</tr>
		
	 </table>
	</#if>

	<div class="row">
		<#assign bPmtDisabled = !((("enabled" == status.paymentEnabled) || ("disableDQ" == status.paymentEnabled)) &&
								  ("activeAccount" == accountStatus) )>
		<div class="col-10">
			<div class="mb-2">
				<span class="fw-bold">Account #:</span> <span class="fw-bold">${displayAccount}</span>
				
			</div>
			<div>
				<#--  IF WE'VE DISABLED VIEW ACCOUNTS, THE LINKS DISAPPER, IF Not Disabled then we do it based on
						account status information -->
				<#if "enabled" == status.viewAccount>
					<#switch accountStatus>
						<#case "activeAccount">
							<#-- All links enabled -->
							<a class="me-4" target="_blank" href="fffcViewDoc?sAccount=${bill.internalAccountNo}&sDate=${bill.dateNum?c}&sStreamId=${bill.stream}&sDocId=${bill.id?c}&sExtDocId=${bill.extDocId}">View statement</a>
							<a class="me-4 text-nowrap" href="#" st-pop-in="fffcViewTransactions?offset=${jumpToOffset}">Transaction History</a>

							<#if bPmtDisabled>
								<#--  payment is disabled -->
								<a class="text-nowrap disabled pe-none opacity-50" aria-disabled="true">Set&nbsp;up&nbsp;recurring&nbsp;payment</a>				
							<#else>
								<#--  payment is enabled -->
								<a class="text-nowrap" href="startAutomaticPayment">Set&nbsp;up&nbsp;recurring&nbsp;payments</a>				
							</#if>
							<#break>
						<#case "newAccount">
						<#case "closedAccount">
						<#case "unknown">
						<#default>
							<#--  IF THERE ARE NO STATUS FOR BILL AVAILABLE THAT MAKES SENSE, DON'T SHOW THE LINKS -->
					</#switch>
				</#if>
			</div>
		</div>
		<div class="col-2">
			<a class="btn btn-primary <#if bPmtDisabled>disabled</#if>" href="startMakePayment" 
										<#if bPmtDisabled>disabled="true"</#if>>PAY THIS BILL</a>
		</div>
	</div>
	
	<#--  HANDLE THE CASE WHERE THIS ACCOUNT HAS GONE BECAUSE OF FRAUD -->
	<#if !("enabled" == status.viewAccount)>
		<div class="text-center mt-3 border border-2 rounded-pill border-danger p-3">
			Your online account access is disabled. Visit or call your local branch immediately to make payment arrangements.
		</div>
		<h2 class="mt-3 pt-3 border-top border-dark row">
			<div class="col fw-bold text-center">
				Account access denied.
			</div>
		</h2>
	<#elseif "activeAccount" == accountStatus>
		<#-- NORMAL CASE WHERE THERE IS A BILL AND WE NEED TO MESSAGE IT --> 
		
		<#--  HANDLE CASE WHERE PAYMENT HAS BEEN DISABLED FOR THIS ACCOUNT -->
		<#switch status.paymentEnabled>
			<#case "enabled">
			<#case "disableDQ"> <#--  to the overview a disableDQ status is really enabled -->
				<#-- HANDLE ACH STATUS ISSUES ENABLED, DISABLED, WHATEVER -->
				<#switch status.achEnabled>
					<#case "enabled">
						<#break> <#--  nothing to show here! -->
					<#case "disabledNSF"> <#-- This message shows when ach is disabled along with other payment and bill messages -->
						<div class="text-center mt-3 border border-2 rounded-pill border-danger p-3">
							Payments made using your bank account number have failed several times, so direct debit (ACH)
							is disabled and any associated scheduled and recurring payments are cancelled. Contact your
							local branch to resolve this. You can pay by debit card if there are sufficient funds
							in your bank account.
						</div>
						<#break>
					<#case "disabledStopACH">
					<#case "disableChargeOff">
					<#default>
						<div class="text-center mt-3 border border-2 rounded-pill border-danger p-3">
							You are not authorized to make payments via direct debit (ACH) and any associated scheduled 
							and recurring payments are cancelled. Contact your local branch to resolve this. You can pay by 
							debit card if there are sufficient funds in your bank account.
						</div>
						<#break>
				</#switch>
	
				<#-- HANDLE ONE TIME PAYMENTS SCHEDULED -->
				<#switch scheduledPayment.oneTimePmtCount>	<#--  The customer has one or more scheduled payments in the queue -->
					<#case "1">
						<#--  Note that not enough turn it into danger from info message -->
						<div class="text-center mt-3 border border-2 rounded-pill <#if bScheduledPaymentsLate>border-danger<#else>border-info</#if> p-3">
							You have scheduled a payment of
							<span class="fw-bold text-decoration-underline">${formatUtils.formatAmount(nScheduledPaymentAmount?number)}</span>
							for this account on <span class="fw-bold text-decoration-underline">${dScheduledPaymentDate?date}</span>.
							<#if bScheduledPaymentsLate> <#--  if true, this payment and automatic aren't enough -->
								This payment and any automatic payment currently scheduled will not meet your obligation to pay
								<span class="fw-bold text-decoration-underline">${formatUtils.formatAmount(nAmountDue?number)}</span> by
								<span class="fw-bold text-decoration-underline">${dDueDate?date}</span>.
							</#if>
						</div>
						<#break>
	
					<#case "0">
						<#break>
					
					<#default>
						<#--  multimple payments there -->
						<div class="text-center mt-3 border border-2 rounded-pill <#if bScheduledPaymentsLate>border-danger<#else>border-info</#if> p-3">
							You have scheduled multiple payments totaling
							<span class="fw-bold text-decoration-underline">${formatUtils.formatAmount(nScheduledPaymentAmount?number)}</span>
							for this account with last payment on <span class="fw-bold text-decoration-underline">${dScheduledPaymentDate?date}</span>.
							<#if bScheduledPaymentsLate> <#--  if true these payments and scheduled aren't enough -->
								These payments and any automatic payment currently scheduled will not meet your obligation to pay
								<span class="fw-bold text-decoration-underline">${formatUtils.formatAmount(nAmountDue?number)}</span> by
								<span class="fw-bold text-decoration-underline">${dDueDate?date}</span>.
							</#if>
						</div>
						<#break>
				</#switch>
				
				<#--  HANDLE AUTOMATIC PAYMENT SCHEDULES -->
				<#if 0 < scheduledPayment.automaticPmtCount?number> <#--  The customer has an automatic payment that's scheduled -->
					<div class="text-center mt-3 border border-2 rounded-pill <#if bScheduledPaymentsLate>border-danger<#else>border-info</#if> p-3">
						You have an automatic payment of
						<span class="fw-bold text-decoration-underline">${formatUtils.formatAmount(nAutomaticPaymentAmount)}</span>
						scheduled for <span class="fw-bold text-decoration-underline">${dAutomaticPaymentDate?date}</span>.
						<#if bScheduledPaymentsLate>
							This payment and any other payments currently scheduled will not meet your obligation to pay
							<span class="fw-bold text-decoration-underline">${formatUtils.formatAmount(nAmountDue)}</span> by
							<span class="fw-bold text-decoration-underline">${dDueDate?date}</span>.
						
						</#if>
					</div>
				</#if>
				
				<#-- HANDLE THE CASE WHERE THERE'S NO PAYMENTS OF ANY KIND SCHEDULED -->
				<#if (( 0 == scheduledPayment.oneTimePmtCount?number) && (0 == scheduledPayment.automaticPmtCount?number)) > 
					
					<#--  HANDLE THE CASE WHERE THE CURRENT BILL IS PAST ITS DUE DATE BUT A NEW BILL HASN'T ARRIVED -->
					<#if bPastDueDate> 
						<div class="text-center mt-3 border border-2 rounded-pill border-danger p-3">
							We want to remind you that 
							<span class="fw-bold text-decoration-underline">${formatUtils.formatAmount(nAmountDue)}</span>
							was due for payment on <span class="fw-bold text-decoration-underline">${dDueDate?date}</span>.
							Please pay now.
						</div>
					<#-- HANDLE THE CASE WHERE THERE'S AN OVERDUE AMOUNT ON THE CURRENT BILL -->
					<#elseif bBillHasOverdue>	
						<div class="text-center mt-3 border border-2 rounded-pill border-danger p-3">
							We want to remind you that 
							<span class="fw-bold text-decoration-underline">${formatUtils.formatAmount(nAmountDue)}</span>
							is due for payment on <span class="fw-bold text-decoration-underline">${dDueDate?date}</span> 
							and includes an overdue amount of 
							<span class="fw-bold text-decoration-underline">
								<#if nAmountOverdue??>
									${formatUtils.formatAmount(nAmountOverdue)}
								<#else>
									missing overdue amount
								</#if>								
							</span>.
							Please pay now to avoid additional charges.
						</div>
					<#--  HANDLE GOOD OLD BILL THAT'S NOT LATE AND DOESN'T CONTAIN ANY OVERDUE AMOUNT -->
					<#else> 
						<div class="text-center mt-3 border border-2 rounded-pill border-info p-3">
							Your next payment of 
							<span class="fw-bold text-decoration-underline">${formatUtils.formatAmount(nAmountDue)}</span>
							is due on <span class="fw-bold text-decoration-underline">${dDueDate?date}</span>. 
						</div>
					</#if>	
				</#if> <#--  ("none" == sScheduledPaymentCount && !bAutomaticPaymentScheduled) -->
				<#break>
			<#case "disabledLastPayment">
				<#if !bBillHasOverdue>
					<#--  last payment with no overdue amount -->
					<div class="text-center mt-3 border border-2 rounded-pill border-info p-3">
						Contratulations! your final payment of 
						<span class="fw-bold text-decoration-underline">${formatUtils.formatAmount(nAmountDue)}</span>
						is due on <span class="fw-bold text-decoration-underline">${dDueDate?date}</span>. Visit your local
						branch to make this payment and close your account.
					</div>
				<#else>
				<#--  last payment with an overdue amount -->
					<div class="text-center mt-3 border border-2 rounded-pill border-danger p-3">
						Contratulations! your final payment of 
						<span class="fw-bold text-decoration-underline">${formatUtils.formatAmount(nAmountDue)}</span>
						is due on <span class="fw-bold text-decoration-underline">${dDueDate?date}</span> and includes an
						overdue amount of <span class="fw-bold text-decoration-underline">${formatUtils.formatAmount(nAmountOverdue)}</span>.
						Visit your local branch now to make this payment, close your account, and avoid addiitonal charges.
					</div>
				</#if>
				<#break>
			
			<#default>
				<div class="text-center mt-3 border border-2 rounded-pill border-danger p-3">
					You are not authorized to create any new payments for this account. Visit or contact your local branch now to 
						correct the issue.
				</div>
				<#break>
		</#switch> <#-- status.payEnabled -->
		
		<h2 class="mt-3 pt-3 border-top border-dark row">
			<div class="col fw-bold">
				${formatUtils.formatAmount(nLoanAmount)} <!--  statement loan balance -->
			</div>
			<div class="col fw-bold text-center">
				${dDueDate?date}
			</div>
			<div class="col">
				<span class="float-end fw-bold">${formatUtils.formatAmount(nAmountDue)}</span>
			</div>
		</h2>
		
		<div class="row">
			<div class="col">
				Statement loan balance
			</div>
			<div class="col text-center">
				Monthly payment due date
			</div>
			<div class="col">
				<span class="float-end">Statement amount due</span>
			</div>
		</div>
	<#else>
		<h2 class="mt-3 pt-3 border-top border-dark row">
			<div class="col text-center">
				Unknown account status, please contact your local branch.
			</div>
		</h2>
	</#if> <#-- bAccessDisabledcollections -->
</div>

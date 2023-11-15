/**
 * 
 */
package com.sorrisotech.svcs.accountstatus.cache;

import java.math.BigDecimal;

/**
 * Interface to the result set that can be queried by calls
 * from the use case. The idea here is that generally, this
 * element provides account status for all the accounts a 
 * user has access to and is results in a single query to 
 * the database for the entire session. 
 * <p>
 * It will get pushed out of the cache if its been sitting
 * unattended for a preset timeout period (defined in the 
 * cache). If it gets pushed out, the cache/factory will 
 * do the query again and create a new one next time it is
 * accessed.
 * 
 * @author John A. Kowalonek
 * @since 25-Sep-2023
 * @version 25-Sep-2023
 * 
 */
public interface IUserStatusCacheItem {
	
	/**
	 * General Account Information that doesn't control
	 * application behavior, but may be used in presentation. 
	 */
	public record GeneralAccountInfo (
		String		statusGroupId,
		String		paymentGroupId,
		String		customerId,
		String 	 	accountId,
		BigDecimal	origLoanAmt,
		BigDecimal	monthlyPayment,
		Integer		totalNumPayments,
		Integer		remainingNumPayments,
		Integer		mostRecentUpdate
		)  {}
	
	/**
	 * Return data for monthly minimum
	 */
	public class MinimumPaymentData {
		
		Boolean mbMinimumRequired = false;
		BigDecimal mdMinimumAmount = new BigDecimal(0);
		
		public MinimumPaymentData (Boolean cbMinimumRequired, BigDecimal cdMinimumAmount) {
			mbMinimumRequired = cbMinimumRequired;
			mdMinimumAmount = cdMinimumAmount;
		}
		
		public Boolean getIsMinimumRequired () {
			return mbMinimumRequired;
		}
		
		public BigDecimal getMinimumAmount () {
			return mdMinimumAmount;
		}
	}
	
	/**
	 * returns General account information that isn't used to change the behavior of the 
	 * application but may need to be presented.
	 * @param cszPaymentGroup  - payment group this account belongs to
	 * @param cszAcctIdentifier - account for which this information is requested
	 * 
	 * @return GeneralAccountInfo - record containing the account data.
	 * @throws AccountStatusException
	 */
	abstract GeneralAccountInfo getGeneralAccountInfo(String cszPaymentGroup, String cszAcctIdentifier) throws AccountStatusException;

	/**
	 * returns the account status value of newAccount, closedAccount, activeAccount
	 * @param cszPaymentGroup - payment group this account belongs to
	 * @param cszAcctIdentifier -- account for which data is requested
	 * 
	 * @return EnumConst.AcctStatus -- result value
	 * @throws AccountStatusException
	 */
	abstract public EnumConst.AcctStatus getAccountStatus(String cszPaymentGroup, String cszAcctIdentifier) throws AccountStatusException;
	
	/**
	 * returns the payment enabled status value of enabled, disabledLastPayment, disabledDelinquent, 
	 * disabledClosed
	 * @param cszPaymentGroup - payment group this account belongs to
	 * @param cszAcctIdentifier -- account for which data is requested
	 * 
	 * @return EnumConst.PayEnabled -- result value
	 * @throws AccountStatusException
	 */
	abstract public EnumConst.PayEnabled getPaymentEnabled(String cszPaymentGroup, String cszAcctIdentifier) throws AccountStatusException;
	
	/**
	 * returns true if payment enabled otherwise false
	 * @param cszPaymentGroup - payment group this account belongs to
	 * @param cszAcctIdentifier -- account for which data is requested
	 * 
	 * @return EnumConst.PayEnabled -- result value
	 * @throws AccountStatusException
	 */
	abstract public Boolean isPaymentEnabled(String cszPaymentGroup, String cszAcctIdentifier) throws AccountStatusException;

	/**
	 * returns the ACH enabled status value of enabled, disabledNSF.  If one
	 * account is disabled, then all are disabled.
	 * 
	 * @return EnumConst.AchEnabled -- result value
	 * @throws AccountStatusException
	 */
	abstract public EnumConst.AchEnabled getAchEnabled() throws AccountStatusException;

	/**
	 * returns true if ACH enabled otherwise false.  If one
	 * account is disabled, then all are disabled.
	 * 
	 * @return EnumConst.AchEnabled -- result value
	 * @throws AccountStatusException
	 */
	abstract public Boolean isAchEnabled() throws AccountStatusException;

	/**
	 * returns the view account status value of enabled, disableAccount, disablePortal
	 * @param cszPaymentGroup - payment group this account belongs to
	 * @param cszAcctIdentifier -- account for which data is requested
	 * 
	 * @return EnumConst.ViewAcct -- result value
	 * @throws AccountStatusException
	 */
	abstract public EnumConst.ViewAcct getViewAccount(String cszPaymentGroup, String cszAcctIdentifier) throws AccountStatusException;
	
	/**
	 * returns true if this user has portal access, otherwise false
	 * 
	 * @return boolean 
	 * @throws AccountStatusException
	 */
	abstract public Boolean hasPortalAccess() throws AccountStatusException;
	
	/**
	 * Returns MonthlyMinimumData object.
	 * 
	 * @return MonthlyMinimumData
	 * @throws AccountStatusException
	 */
	abstract public MinimumPaymentData getMinimumPaymentAmt(String cszPaymentGroup, String cszAcctIdentifier) throws AccountStatusException;
}

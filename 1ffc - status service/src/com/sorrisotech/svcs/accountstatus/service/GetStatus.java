package com.sorrisotech.svcs.accountstatus.service;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.sorrisotech.svcs.accountstatus.api.IApiAccountStatus;
import com.sorrisotech.svcs.accountstatus.cache.AccountStatusException;
import com.sorrisotech.svcs.accountstatus.cache.IUserStatusCacheItem;
import com.sorrisotech.svcs.accountstatus.cache.UserStatusCache;
import com.sorrisotech.svcs.serviceapi.api.IRequestInternal;
import com.sorrisotech.svcs.serviceapi.api.ServiceAPIErrorCode;



/**
 *  Provides use case with account status information. Specifically implements response to the <code>GetStatus</code> call in the 
 *  <code>accountStatus</code> service.
 *  
 *  @param user -			userId for the logged in user.
 *  @param statusGroup -	payment group containing account status information.
 *  @param accountNumber - 	internal account number for this request.
 *  
 *  @return <li><b>accountStatus</b> -	status of the account: new, closed, active.
 *  		<li><b>paymentEnabled</b> -	can this account be paid, if not why: enabled, disabledDelinquency, disabledClosed.
 *  		<li><b>achEnabled</b> -		is ACH enabled and if not why: enabled, disabledNSF.
 *  		<li><b>viewAccount</b> -	can user view this account, if not at what level is it disabled: enabled, disableAccount, disablePortal.
 *  
 *  @version 24-Sep-2023
 *  @since 24-Sep-2023
 *  @author John A. Kowalonek 
 */
public class GetStatus extends GetStatusBase {
	
	private static final Logger LOG = LoggerFactory.getLogger(GetStatus.class);
	private static final long serialVersionUID = 494299061637493608L;

	@Override
	protected ServiceAPIErrorCode processInternal(IRequestInternal request) {

		final String sUser		 	= request.getString(IApiAccountStatus.GetStatus.user);
		final String sPaymentGroup 	= request.getString(IApiAccountStatus.GetStatus.paymentGroup);
		final String sAccount		= request.getString(IApiAccountStatus.GetStatus.account);

		LOG.debug("GetStatus:processInternal -- entered method for user {}, group {}, acct {}", 
				sUser, sPaymentGroup, sAccount);
		
		ServiceAPIErrorCode rVal = ServiceAPIErrorCode.Failure;
		IUserStatusCacheItem cacheItem = UserStatusCache.getItem(sUser);
		request.setToResponse();
		
		if (null != cacheItem) {
			try {
				// -- return detailed status on the specified account -- 
				request.set(IApiAccountStatus.GetStatus.accountStatus, 
							cacheItem.getAccountStatus(sPaymentGroup, sAccount).toString());
				request.set(IApiAccountStatus.GetStatus.paymentEnabled, 
						cacheItem.getPaymentEnabled(sPaymentGroup, sAccount).toString());
				request.set(IApiAccountStatus.GetStatus.achEnabled, 
						cacheItem.getAchEnabled().toString());
				request.set(IApiAccountStatus.GetStatus.viewAccount, 
						cacheItem.getViewAccount(sPaymentGroup, sAccount).toString());
				rVal = ServiceAPIErrorCode.Success;
			} catch (AccountStatusException e) {
				LOG.error("GetStatus:processInternal -- failed to get status for user {}, group {}, acct {}",
						sUser, sPaymentGroup, sAccount, e);
				rVal = ServiceAPIErrorCode.InternalFailure;
			}
		}
		request.setStatus(rVal);
		return rVal;
	}
}
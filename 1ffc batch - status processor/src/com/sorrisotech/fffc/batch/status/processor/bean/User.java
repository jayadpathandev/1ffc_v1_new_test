/* (c) Copyright 2016-2023 Sorriso Technologies, Inc(r), All Rights Reserved, 
 * Patents Pending.
 * 
 * This product is distributed under license from Sorriso Technologies, Inc.
 * Use without a proper license is strictly prohibited.  To license this
 * software, you may contact Sorriso Technologies at:
 * 
 * Sorriso Technologies, Inc.
 * 400 West Cummings Park,
 * Suite 1725-184,
 * Woburn, MA 01801, USA
 * +1.978.635.3900
 * 
 * "Sorriso Technologies", "You and Your Customers Together, Online", "Persona 
 * Solution Suite by Sorriso", the Sorriso Logo and Persona Solution Suite Logo
 * are all Registered Trademarks of Sorriso Technologies, Inc.  "Information Is
 * The New Online Currency", "e-TransPromo", "Persona Enterprise Edition", 
 * "Persona SaaS", "Persona Services", "SPN - Synergy Partner Network", 
 * "Sorriso Synergy", "Our DNA Is In Online", "Persona E-Bill & E-Pay", 
 * "Persona E-Service", "Persona Customer Intelligence", "Persona Active 
 * Marketing", and "Persona Powered By Sorriso" are trademarks of Sorriso
 * Technologies, Inc.
 */
package com.sorrisotech.fffc.batch.status.processor.bean;

import java.util.List;

/**************************************************************************************************
 * Class which holds records for User.
 * 
 * @author Rohit Singh
 * 
 */
public class User {
	
	/**************************************************************************
	 * Ids of the user.
	 */
	private String m_szUserId;
	
	/**************************************************************************
	 * Flag denotes if the payment is diabled.
	 */
	private boolean m_bPaymentDisabled;
	
	/**************************************************************************
	 * Flag denotes if the ach is diabled.
	 */
	private boolean m_bAchDisabled;
	
	/**************************************************************************
	 * List of all scheduled payment records for user.
	 */
	private List<ScheduledPayment> m_cScheduledPayments;
	
	/**************************************************************************
	 * List of all recurring payment records for user.
	 */
	private List<RecurringPayment> m_cRecurringPayments;

	/**************************************************************************
	 * Gets the value of m_szUserId.
	 * 
	 * @return m_szUserId
	 */
	public String getUserId() {
		return m_szUserId;
	}

	/**************************************************************************
	 * Sets the value of m_szUserId.
	 * @param userId
	 */
	public void setUserId(String userId) {
		this.m_szUserId = userId;
	}

	/**************************************************************************
	 * Gets the value of m_bPaymentDisabled.
	 * 
	 * @return m_bPaymentDisabled
	 */
	public boolean isPaymentDisabled() {
		return m_bPaymentDisabled;
	}

	/**************************************************************************
	 * Sets the value of m_bPaymentDisabled.
	 * 
	 * @param paymentDisabled
	 */
	public void setPaymentDisabled(boolean paymentDisabled) {
		this.m_bPaymentDisabled = paymentDisabled;
	}

	/**************************************************************************
	 * Gets the value of m_bAchDisabled.
	 * 
	 * @return m_bAchDisabled
	 */
	public boolean isAchDisabled() {
		return m_bAchDisabled;
	}

	/**************************************************************************
	 * Sets the value of m_bAchDisabled.
	 * 
	 * @param achDiabled
	 */
	public void setAchDisabled(boolean achDiabled) {
		this.m_bAchDisabled = achDiabled;
	}

	/**************************************************************************
	 * Gets the value of m_cScheduledPayments.
	 * 
	 * @return list of ScheduledPayment
	 */
	public List<ScheduledPayment> getScheduledPayments() {
		return m_cScheduledPayments;
	}

	/**************************************************************************
	 * Sets the value of m_cScheduledPayments.
	 * 
	 * @param scheduledPayments list of ScheduledPayment
	 */
	public void setScheduledPayments(List<ScheduledPayment> scheduledPayments) {
		this.m_cScheduledPayments = scheduledPayments;
	}

	/**************************************************************************
	 * Gets the value of m_cRecurringPayments.
	 * 
	 * @return list of RecurringPayment
	 */
	public List<RecurringPayment> getRecurringPayments() {
		return m_cRecurringPayments;
	}

	/**************************************************************************
	 * Sets the value of m_cRecurringPayments.
	 * 
	 * @param recurringPayments list of RecurringPayment
	 */
	public void setRecurringPayments(List<RecurringPayment> recurringPayments) {
		this.m_cRecurringPayments = recurringPayments;
	}

}
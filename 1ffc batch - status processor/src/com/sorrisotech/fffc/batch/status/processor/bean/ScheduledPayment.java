/* (c) Copyright 2016-2024 Sorriso Technologies, Inc(r), All Rights Reserved, 
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

import java.math.BigDecimal;
import java.util.Date;

/**************************************************************************************************
 * Class which holds records for scheduled payments.
 * 
 * @author Rohit Singh
 * 
 */
public class ScheduledPayment {
	
	/**************************************************************************
	 * Scheduled payment record Id
	 */
	private String m_szId;
	
	/**************************************************************************
	 * Account number for which the payment is scheduled
	 */
	private String m_szAccounutNumber;
	
	/**************************************************************************
	 * Payment scheduled date
	 */
	private Date m_cScheduledPaymentDate;
	
	/**************************************************************************
	 * Source name for the scheduled payment
	 */
	private String m_szWalletNickName;
	
	/**************************************************************************
	 * Amount of the scheduled payment
	 */
	private BigDecimal m_cAmount;
	
	/**************************************************************************
	 * Type of the source
	 */
	private String m_szSourceType;
	
	/**************************************************************************
	 * Internal account number for which the payment is scheduled
	 */
	private String m_szInternalAccount;
	
	/**************************************************************************
	 * Payment group.
	 */
	private String m_szPayGroup;
	
	/**************************************************************************
	 * Scheduled record userId.
	 */
	private String m_szUserId;
	
	/**************************************************************************
	 * Gets the value of m_szId
	 * 
	 * @return
	 */
	public String getId() {
		return m_szId;
	}

	/**************************************************************************
	 * Sets value of m_szId
	 * 
	 * @param id
	 */
	public void setId(String id) {
		this.m_szId = id;
	}

	/**************************************************************************
	 * Gets the value of m_szAccounutNumber
	 * 
	 * @return
	 */
	public String getAccounutNumber() {
		return m_szAccounutNumber;
	}

	/**************************************************************************
	 * Sets the value of m_szAccounutNumber
	 * 
	 * @param accounutNumber
	 */
	public void setAccounutNumber(String accounutNumber) {
		this.m_szAccounutNumber = accounutNumber;
	}

	/**************************************************************************
	 * Gets the value of m_cScheduledPaymentDate
	 * 
	 * @return
	 */
	public Date getScheduledPaymentDate() {
		return m_cScheduledPaymentDate;
	}

	/**************************************************************************
	 * Sets the value of m_cScheduledPaymentDate
	 * 
	 * @param scheduledPaymentDate
	 */
	public void setScheduledPaymentDate(Date scheduledPaymentDate) {
		this.m_cScheduledPaymentDate = scheduledPaymentDate;
	}

	/**************************************************************************
	 * Gets the value of m_szWalletNickName
	 * 
	 * @return
	 */
	public String getWalletNickName() {
		return m_szWalletNickName;
	}

	/**************************************************************************
	 * Sets the value of m_szWalletNickName
	 * 
	 * @param walletNickName
	 */
	public void setWalletNickName(String walletNickName) {
		this.m_szWalletNickName = walletNickName;
	}

	/**************************************************************************
	 * Gets the value of m_cAmount
	 * 
	 * @return
	 */
	public BigDecimal getAmount() {
		return m_cAmount;
	}

	/**************************************************************************
	 * Sets the value of m_cAmount
	 * 
	 * @param amount
	 */
	public void setAmount(BigDecimal amount) {
		this.m_cAmount = amount;
	}

	/**************************************************************************
	 * Gets the value of m_szSourceType
	 * 
	 * @return
	 */
	public String getSourceType() {
		return m_szSourceType;
	}

	/**************************************************************************
	 * Sets the value of m_szSourceType
	 * 
	 * @param sourceType
	 */
	public void setSourceType(String sourceType) {
		this.m_szSourceType = sourceType;
	}
	
	/**************************************************************************
	 * Getter method for internal account number.
	 * @return the internal account number
	 */
	public String getInternalAccount() {
		return m_szInternalAccount;
	}

	/**************************************************************************
	 * Setter method for internal account number.
	 * @param internalAccount The internal account number to set.
	 */
	public void setInternalAccount(String internalAccount) {
		this.m_szInternalAccount = internalAccount;
	}

	/**************************************************************************
	 * Getter method for payment group.
	 * @return the payGroup
	 */
	public String getPayGroup() {
		return m_szPayGroup;
	}

	/**************************************************************************
	 * @param payGroup the payGroup to set
	 */
	public void setPayGroup(String payGroup) {
		this.m_szPayGroup = payGroup;
	}
	
	/**************************************************************************
	 * Getter method for user id.
	 * @return the userId
	 */
	public String getUserId() {
		return m_szUserId;
	}

	/**************************************************************************
	 * Setter method for user id.
	 */
	public void setUserId(String userId) {
		this.m_szUserId = userId;
	}

	@Override
	public String toString() {
		return "ScheduledPayment [m_szId=" + m_szId + ", m_szAccounutNumber=" + m_szAccounutNumber
				+ ", m_cScheduledPaymentDate=" + m_cScheduledPaymentDate + ", m_szWalletNickName=" + m_szWalletNickName
				+ ", m_cAmount=" + m_cAmount + ", m_szSourceType=" + m_szSourceType + ", m_szInternalAccount="
				+ m_szInternalAccount + ", m_szPayGroup=" + m_szPayGroup + ", m_szUserId=" + m_szUserId + "]";
	}	
	
}
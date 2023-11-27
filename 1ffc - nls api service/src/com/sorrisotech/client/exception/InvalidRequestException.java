/*
 * (c) Copyright 2023 Sorriso Technologies, Inc(r), All Rights Reserved, Patents
 * Pending.
 *
 * This product is distributed under license from Sorriso Technologies, Inc. Use
 * without a proper license is strictly prohibited. To license this software,
 * you may contact Sorriso Technologies at:
 *
 * Sorriso Technologies, Inc. 40 Nagog Park Acton, MA 01720 +1.978.635.3900
 *
 * "Sorriso Technologies", "You and Your Customers Together, Online", "Persona
 * Solution Suite by Sorriso", the Sorriso Logo and Persona Solution Suite Logo
 * are all Registered Trademarks of Sorriso Technologies, Inc. "Information Is
 * The New Online Currency", "e-TransPromo", "Persona Enterprise Edition",
 * "Persona SaaS", "Persona Services", "SPN - Synergy Partner Network",
 * "Sorriso Synergy", "Our DNA Is In Online", "Persona E-Bill & E-Pay",
 * "Persona E-Service", "Persona Customer Intelligence", "Persona Active
 * Marketing", and "Persona Powered By Sorriso" are trademarks of Sorriso
 * Technologies, Inc.
 */
package com.sorrisotech.client.exception;

/******************************************************************************
 * Exception handling class for invalid request.
 * 
 * @author Asrar Saloda
 */
public class InvalidRequestException extends RuntimeException {
	
	private static final long serialVersionUID = 5754925205807211737L;
	
	/****************************************************************************
	 * No argument constructor.
	 */
	public InvalidRequestException() {
		super();
	}
	
	/****************************************************************************
	 * Argument constructor which takes message and calls super class constructor
	 * 
	 * @param szMessage Exception message.
	 */
	public InvalidRequestException(String szMessage) {
		super(szMessage);
	}
}
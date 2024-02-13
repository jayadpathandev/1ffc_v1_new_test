// (c) Copyright 2024 Sorriso Technologies, Inc(r), All Rights Reserved,
// Patents Pending.
//
// This product is distributed under license from Sorriso Technologies, Inc.
// Use without a proper license is strictly prohibited.  To license this
// software, you may contact Sorriso Technologies at:

// Sorriso Technologies, Inc.
// 400 West Cummings Park
// Suite 1725-184
// Woburn, MA 01801, USA
// +1.978.635.3900

// "Sorriso Technologies", "You and Your Customers Together, Online", "Persona
// Solution Suite by Sorriso", the Sorriso Logo and Persona Solution Suite Logo
// are all Registered Trademarks of Sorriso Technologies, Inc.  "Information Is
// The New Online Currency", "e-TransPromo", "Persona Enterprise Edition",
// "Persona SaaS", "Persona Services", "SPN - Synergy Partner Network",
// "Sorriso Synergy", "Our DNA Is In Online", "Persona E-Bill & E-Pay",
// "Persona E-Service", "Persona Customer Intelligence", "Persona Active
// Marketing", and "Persona Powered By Sorriso" are trademarks of Sorriso
// Technologies, Inc.

export interface GeoLocation {
    latitude: number;
    longitude: number;
}

export function geoip_elements(parent: HTMLElement): void {
    const geoInputElements = $(parent).find('input[r_sorriso-geo]');
    
    if (geoInputElements.length === 0) {
        return;
    }

    geoInputElements.each((_, elem) => {
        navigator.geolocation.getCurrentPosition((position) => {
            const { latitude, longitude }: GeoLocation = position.coords;
            $(elem).attr('value', `${latitude}, ${longitude}`);
        });
    });
}
  

  
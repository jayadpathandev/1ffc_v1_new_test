// (c) Copyright 2021-2022 Sorriso Technologies, Inc(r), All Rights Reserved,
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
import $ from 'jquery';

//*****************************************************************************
// Makes a group of dropdowns unqiue (except for the first item).
export function shared_dropdowns_except_first(
            parent : HTMLElement
        ) {

    $(parent).find('*[st-shared-dropdowns-except-first]').each(function () {
        const that      = this;
        const groupName = $(that).attr('st-shared-dropdowns-except-first') as string;
        const $all      = $(parent).find('*[st-shared-dropdowns-except-first="' + groupName + '"]');
        let   current   = $(that).val() as string;

        function adjust(value:string, disable:boolean) {
            const selector = 'option[value="' + value + '"]';

            if ($(that).find(selector).is(':first-child') == false) {
                if (disable == true) {
                    $all.find(selector).prop('disabled', disable);
                    $(that).find(selector).prop('disabled', !disable);
                } else {
                    $all.find(selector).prop('disabled', false);
                }
            }
        }

        adjust(current, true);

        $(that).on('change', function() {
            const value = $(this).val() as string;

            if (value !== current) {
                adjust(current, false);
                adjust(value, true);
                current = value;
            }
        });
    });
}

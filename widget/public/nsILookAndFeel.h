/* -*- Mode: C++; tab-width: 4; indent-tabs-mode: nil; c-basic-offset: 4 -*-
 *
 * The contents of this file are subject to the Netscape Public
 * License Version 1.1 (the "License"); you may not use this file
 * except in compliance with the License. You may obtain a copy of
 * the License at http://www.mozilla.org/NPL/
 *
 * Software distributed under the License is distributed on an "AS
 * IS" basis, WITHOUT WARRANTY OF ANY KIND, either express or
 * implied. See the License for the specific language governing
 * rights and limitations under the License.
 *
 * The Original Code is mozilla.org code.
 *
 * The Initial Developer of the Original Code is Netscape
 * Communications Corporation.  Portions created by Netscape are
 * Copyright (C) 1998 Netscape Communications Corporation. All
 * Rights Reserved.
 *
 * Contributor(s): 
 */

#ifndef __nsILookAndFeel
#define __nsILookAndFeel
#include "nsISupports.h"
#include "nsColor.h"
#include "nsFont.h"

#ifdef NS_DEBUG
#include "nsSize.h"
#endif


// {21B51DE1-21A3-11d2-B6E0-00805F8A2676}
#define NS_ILOOKANDFEEL_IID \
{ 0x21b51de1, 0x21a3, 0x11d2, \
    { 0xb6, 0xe0, 0x0, 0x80, 0x5f, 0x8a, 0x26, 0x76 } }

class nsILookAndFeel: public nsISupports {
public:
    NS_DEFINE_STATIC_IID_ACCESSOR(NS_ILOOKANDFEEL_IID)

  typedef enum {
    eColor_WindowBackground,
    eColor_WindowForeground,
    eColor_WidgetBackground,
    eColor_WidgetForeground,
    eColor_WidgetSelectBackground,
    eColor_WidgetSelectForeground,
    eColor_Widget3DHighlight,
    eColor_Widget3DShadow,
    eColor_TextBackground,
    eColor_TextForeground,
    eColor_TextSelectBackground,
    eColor_TextSelectForeground,

    // New CSS 2 color definitions
    eColor_activeborder,
    eColor_activecaption,
    eColor_appworkspace,
    eColor_background,
    eColor_buttonface,
    eColor_buttonhighlight,
    eColor_buttonshadow,
    eColor_buttontext,
    eColor_captiontext,
    eColor_graytext,
    eColor_highlight,
    eColor_highlighttext,
    eColor_inactiveborder,
    eColor_inactivecaption,
    eColor_inactivecaptiontext,
    eColor_infobackground,
    eColor_infotext,
    eColor_menu,
    eColor_menutext,
    eColor_scrollbar,
    eColor_threeddarkshadow,
    eColor_threedface,
    eColor_threedhighlight,
    eColor_threedlightshadow,
    eColor_threedshadow,
    eColor_window,
    eColor_windowframe,
    eColor_windowtext,

    // Colors which will hopefully become CSS3
    eColor__moz_field,
    eColor__moz_dragtargetzone,				//used to highlight valid regions to drop something onto

    //colours needed by Mac Classic skin
    eColor__moz_mac_focusring,				//ring around text fields and lists
    eColor__moz_mac_menuselect,				//colour used when mouse is over a menu item
    eColor__moz_mac_menushadow,				//colour used to do shadows on menu items
    eColor__moz_mac_menutextselect,			//colour used to display text while mouse is over a menu item
    
  	//all of the accert colours
  	eColor__moz_mac_accentlightesthighlight,
    eColor__moz_mac_accentregularhighlight,
    eColor__moz_mac_accentface,
    eColor__moz_mac_accentlightshadow,
    eColor__moz_mac_accentregularshadow,
    eColor__moz_mac_accentdarkshadow,
    eColor__moz_mac_accentdarkestshadow
  
  
  } nsColorID;

  typedef enum {
    eMetric_WindowTitleHeight,
    eMetric_WindowBorderWidth,
    eMetric_WindowBorderHeight,
    eMetric_Widget3DBorder,
    eMetric_TextFieldBorder,                              // Native border size
    eMetric_TextFieldHeight,
    eMetric_TextVerticalInsidePadding,                    // needed only because of GTK
    eMetric_TextShouldUseVerticalInsidePadding,           // needed only because of GTK
    eMetric_TextHorizontalInsideMinimumPadding,  
    eMetric_TextShouldUseHorizontalInsideMinimumPadding,  // needed only because of GTK
    eMetric_ButtonHorizontalInsidePaddingNavQuirks,  
    eMetric_ButtonHorizontalInsidePaddingOffsetNavQuirks, 
    eMetric_CheckboxSize,
    eMetric_RadioboxSize,
    
    eMetric_ListShouldUseHorizontalInsideMinimumPadding,  // needed only because of GTK
    eMetric_ListHorizontalInsideMinimumPadding,         

    eMetric_ListShouldUseVerticalInsidePadding,           // needed only because of GTK
    eMetric_ListVerticalInsidePadding,                    // needed only because of GTK

    eMetric_CaretBlinkTime,                               // default, may be overriden by OS
    eMetric_SingleLineCaretWidth,                         // pixel width of caret in a single line field
    eMetric_MultiLineCaretWidth,                          // pixel width of caret in a multi-line field
    eMetric_ShowCaretWhenSelection,                       // show the caret when text is selected?
    eMetric_SubmenuDelay,                                 // delay before submenus open
    eMetric_MenusCanOverlapOSBar,                         // can popups overlap menu/task bar?
    eMetric_DragFullWindow,                               // show window contents while dragging?
    
    eMetric_ScrollArrowStyle,                             // position of scroll arrows in a scrollbar
    eMetric_ScrollSliderStyle                             // is scroll thumb proportional or fixed?
  } nsMetricID;

  enum {
    eMetric_ScrollArrowStyleSingle,                       // single arrow at each end
    eMetric_ScrollArrowStyleBothAtBottom,                 // both arrows at bottom/right, none at top/left
    eMetric_ScrollArrowStyleBothAtEachEnd,                // both arrows at both ends
    eMetric_ScrollArrowStyleBothAtTop                     // both arrows at top/left, none at bottom/right
  };
  enum {
    eMetric_ScrollThumbStyleNormal,
    eMetric_ScrollThumbStyleProportional
  };
  
  typedef enum {
    eMetricFloat_TextFieldVerticalInsidePadding,
    eMetricFloat_TextFieldHorizontalInsidePadding,
    eMetricFloat_TextAreaVerticalInsidePadding,
    eMetricFloat_TextAreaHorizontalInsidePadding,
    eMetricFloat_ListVerticalInsidePadding,
    eMetricFloat_ListHorizontalInsidePadding,
    eMetricFloat_ButtonVerticalInsidePadding,
    eMetricFloat_ButtonHorizontalInsidePadding
  } nsMetricFloatID;

  
  NS_IMETHOD GetColor(const nsColorID aID, nscolor &aColor) = 0;
  NS_IMETHOD GetMetric(const nsMetricID aID, PRInt32 & aMetric) = 0;
  NS_IMETHOD GetMetric(const nsMetricFloatID aID, float & aMetric) = 0;


#ifdef NS_DEBUG
  typedef enum {
    eMetricSize_TextField = 0,
    eMetricSize_TextArea  = 1,
    eMetricSize_ListBox   = 2,
    eMetricSize_ComboBox  = 3,
    eMetricSize_Radio     = 4,
    eMetricSize_CheckBox  = 5,
    eMetricSize_Button    = 6
  } nsMetricNavWidgetID;

  typedef enum {
    eMetricSize_Courier   = 0,
    eMetricSize_SansSerif = 1
  } nsMetricNavFontID;

  // This method returns the actual (or nearest estimate) 
  // of the Navigator size for a given form control for a given font
  // and font size. This is used in NavQuirks mode to see how closely
  // we match its size
  NS_IMETHOD GetNavSize(const nsMetricNavWidgetID aWidgetID,
                        const nsMetricNavFontID   aFontID, 
                        const PRInt32             aFontSize, 
                        nsSize &aSize) = 0;
#endif
};

#define nsLAF nsILookAndFeel

	// On the Mac, GetColor(eColor_TextSelectForeground, color) returns this
	// constant to specify that the foreground color should not be changed
	// (ie. a colored text keeps its colors  when selected).
	// Of course if other plaforms work like the Mac, they can use it too.
#define NS_DONT_CHANGE_COLOR 	NS_RGB(0x01, 0x01, 0x01)


#endif /* __nsILookAndFeel */

﻿/**
 * Management_UserInterface menu support.
 *
 * Copyright: <a href="http://www.boost.org/LICENSE_1_0.txt">Boost License 1.0</a>.
 * Authors: $(LINK2 http://cattermole.co.nz, Richard Andrew Cattermole)
 */
module cf.spew.ui.features.menu;
import cf.spew.instance;
import devisualization.image : ImageStorage;
import std.experimental.color : RGB8;
import devisualization.util.core.memory.managed;

interface Have_Management_MenuCreator {
	void assignMenu();
}

interface Have_Management_Menu {
	Feature_Management_Menu __getFeatureMenu();
}

interface Feature_Management_Menu {
	Management_MenuItem addItem();
	@property managed!(Management_MenuItem[]) items();
}

///
alias Management_MenuCallback = void delegate(Management_MenuItem);

///
interface Management_MenuItem {
	///
	Management_MenuItem addItem();
	///
	void remove();
	
	@property {
		///
		managed!(Management_MenuItem[]) childItems();
		
		///
		managed!(ImageStorage!RGB8) image();
		
		///
		void image(scope ImageStorage!RGB8);
		
		///
		managed!dstring text();
		
		///
		void text(dstring);
		
		///
		void text(wstring);
		
		///
		void text(string);
		
		///
		bool divider();
		
		///
		void divider(bool);
		
		///
		bool disabled();
		
		///
		void disabled(bool);
		
		/// Not valid if there are children
		void callback(Management_MenuCallback);
	}
}

///
void assignMenu(scope shared(Management_UserInterface) self) {
	if (Have_Management_MenuCreator ss = cast(Have_Management_MenuCreator)self) {
		ss.assignMenu();
	}
}

@property {
	/// Retrives the menu instance or null if non existant
	Feature_Management_Menu menu(scope shared(Management_UserInterface) self) {
		if (!self.capableOfMenu)
			return null;
		else {
			return (cast(Have_Management_Menu)self).__getFeatureMenu();
		}
	}
	
	/**
	 * Does the given user interface manager have a menu?
	 * 
	 * Params:
	 * 		self	=	The user interface manager instance
	 * 
	 * Returns:
	 * 		If the platform supports having an menu
	 */
	bool capableOfMenu(scope shared(Management_UserInterface) self) {
		if (self is null)
			return false;
		else if (auto ss = cast(Have_Management_Menu)self)
			return ss.__getFeatureMenu() !is null;
		else
			return false;
	}
}

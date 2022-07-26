'reach 0.1';
'use strict'
// -----------------------------------------------
// Name: Template
// Description: Reach App using Constructor
// Author: Nicholas Shellabarger
// Version: 0.0.6 - update version
// Requires Reach v0.1.7 (stable)
// ----------------------------------------------
import { useConstructor } from '@nash-protocol/starter-kit#carbon-v0.1.10r0:util.rsh'
import { Participants as AppParticipants,Views, Api, App, Event } from 'interface.rsh'
export const main = Reach.App(() => 
  App(useConstructor(AppParticipants, Views, Api, Event)));
// ----------------------------------------------

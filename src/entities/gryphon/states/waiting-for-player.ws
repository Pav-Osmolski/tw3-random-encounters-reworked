
// When the gryphon is on the ground waiting for the player to attack it
// The gryphon is feeding on a dead beast on the ground. You have to find
// it with tracks and blood spills on the ground.
// ENTRY-POINT state.
state WaitingForPlayer in RandomEncountersReworkedGryphonHuntEntity {
  var bloodtrail_current_position: Vector;
  var bloodtrail_target_position: Vector;
  event OnEnterState(previous_state_name: name) {
    super.OnEnterState(previous_state_name);

    LogChannel('modRandomEncounters', "Gryphon - State WaitingForPlayer");

    this.WaitingForPlayer_Main();
  }

  entry function WaitingForPlayer_Main() {
    this.bloodtrail_target_position = parent.this_actor.GetWorldPosition();
    this.bloodtrail_current_position = thePlayer.GetWorldPosition() + VecRingRand(2, 4);

    this.placeHorseCorpse(this.bloodtrail_current_position);

		thePlayer.PlayVoiceset( 90, "MiscBloodTrail" );  

    parent.AddTimer('WaitingForPlayer_drawLineOfBloodToGryphon', 0.25, true);
    parent.AddTimer('WaitingForPlayer_intervalDefaultFunction', 0.5, true);

    parent.this_newnpc.ChangeStance( NS_Normal );
    parent.this_newnpc.SetBehaviorVariable( '2high', 0 );
    parent.this_newnpc.SetBehaviorVariable( '2low', 0 );
    parent.this_newnpc.SetBehaviorVariable( '2ground', 1 );

    parent.this_newnpc.SetUnstoppable(true);
  }

  private latent function placeHorseCorpse(position: Vector) {
    var horse_template: CEntityTemplate;

    horse_template = (CEntityTemplate)LoadResourceAsync(
      "items\quest_items\q103\q103_item__horse_corpse_with_head_lying_beside_it_02.w2ent",
      true
    );

    FixZAxis(position);

    theGame.CreateEntity(horse_template, position, RotRand(0, 360));
  }

  timer function WaitingForPlayer_intervalDefaultFunction(optional dt : float, optional id : Int32) {
    parent.killNearbyEntities(parent.this_actor);
    
    parent.this_actor.SetTemporaryAttitudeGroup(
      'q104_avallach_friendly_to_all',
      AGP_Default
    );

    parent.this_newnpc.ForgetAllActors();

    if (parent.this_actor.IsInCombat() && parent.this_actor.GetTarget() == thePlayer
    // the distance here is squared for performances reasons, so 400 = 20*20
    // the squareroot is a costly operation. So it's better to multiply the other
    // side and compare it to the squared value (distance).
     || VecDistanceSquared(thePlayer.GetWorldPosition(), parent.this_actor.GetWorldPosition()) < 400
     || parent.this_actor.GetDistanceFromGround(1000) > 3
    ) {
      parent.GotoState('GryphonFleeingPlayer');

      return;
    }

    parent.this_newnpc.ChangeStance( NS_Normal );
    parent.this_newnpc.SetBehaviorVariable( '2high', 0 );
    parent.this_newnpc.SetBehaviorVariable( '2low', 0 );
    parent.this_newnpc.SetBehaviorVariable( '2ground', 1 );

    parent.this_actor.ForceAIBehavior(parent.animation_slot, BTAP_Emergency);
  }

  // I'm making it a timer because spawning too many entities
  // in one go did not go well for the game. It crashed sometimes.
  // It's a way to drop blood splats smoothly over time.
  // the cons is that if the player is running really fast he can
  // see the blood splats appearing.
  timer function WaitingForPlayer_drawLineOfBloodToGryphon(optional dt : float, optional id : Int32) {
    var heading_to_target: float;

    heading_to_target = VecHeading(this.bloodtrail_target_position - this.bloodtrail_current_position);

    this.bloodtrail_current_position += VecConeRand(
      heading_to_target,
      80, // 80 degrees randomness
      1,
      2
    );

    FixZAxis(this.bloodtrail_current_position);

    LogChannel('modRandomEncounters', "line of blood to gryphon, current position: " + VecToString(this.bloodtrail_current_position) + " target position: " + VecToString(this.bloodtrail_target_position));


    parent.addBloodTrackHere(this.bloodtrail_current_position);

    if (VecDistanceSquared(this.bloodtrail_current_position, this.bloodtrail_target_position) < 5 * 5) {
      parent.RemoveTimer('WaitingForPlayer_drawLineOfBloodToGryphon');
    }
  }

  event OnLeaveState( nextStateName : name ) {
    var i: int;

    parent.RemoveTimer('WaitingForPlayer_intervalDefaultFunction');
    parent.RemoveTimer('WaitingForPlayer_drawLineOfBloodToGryphon');

    // copied from regular RE, not sure about it.
    for(i=0; i<100; i+=1) {
      parent.this_actor.CancelAIBehavior(i);
    }

    parent.this_newnpc.SetUnstoppable(false);


    super.OnLeaveState(nextStateName);
  }
}

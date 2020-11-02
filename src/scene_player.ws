

enum RER_CameraTargetType {
  // when you want the camera to target a node, the node can move
  RER_CameraTargetType_NODE = 0,

  // when you want the camera to target a static position
  RER_CameraTargetType_STATIC = 1,

  // when you want the camera to target a bone component, it can move
  RER_CameraTargetType_BONE = 3
}

enum RER_CameraPositionType {
  // the position will be absolute positions
  RER_CameraPositionType_ABSOLUTE = 0,

  // the position will be relative to the camera's current position.
  RER_CameraPositionType_RELATIVE = 1,
}

enum RER_CameraVelocityType {
  // relative to the rotation of the camera
  RER_CameraVelocityType_RELATIVE = 0,

  RER_CameraVelocityType_ABSOLUTE = 1,
  
  RER_CameraVelocityType_FORWARD = 2,
}

struct RER_CameraScene {
  // where the camera is placed
  var position_type: RER_CameraPositionType;
  var position: Vector;

  // where the camera is looking
  var look_at_target_type: RER_CameraTargetType;
  var look_at_target_node: CNode;
  var look_at_target_static: Vector;
  var look_at_target_bone: CAnimatedComponent;

  var duration: float;

  var velocity_type: RER_CameraVelocityType;
  var velocity: Vector;

  // 1 means no blending at all, while 0 means so much blending it won't move at
  // all
  var position_blending_ratio: float;
  var rotation_blending_ratio: float;
}

class RER_StaticCamera extends CStaticCamera {
  public function start() {
    this.Run();
  }

  public latent function playCameraScenes(scenes: array<RER_CameraScene>) {
    var i: int;
    var current_scene: RER_CameraScene;

    for (i = 0; i < scenes.Size(); i += 1) {
      current_scene = scenes[i];

      playCameraScene(current_scene);
    }
  }

  private function getRotation(scene: RER_CameraScene, current_position: Vector): EulerAngles {
    var current_rotation: EulerAngles;

    switch (scene.look_at_target_type) {
      // TODO:
      // case RER_CameraTargetType_BONE:
      //   this.LookAtBone(scene.look_at_target_bone, scene.duration, scene.blend_time);
      //   break;

      case RER_CameraTargetType_STATIC:
        current_rotation = VecToRotation(scene.look_at_target_static - current_position);
        break;

      case RER_CameraTargetType_NODE:
        current_rotation = VecToRotation(scene.look_at_target_node.GetWorldPosition() - current_position);
        break;
    }

    // because the Pitch (Y axis) is inverted by default
    current_rotation.Pitch *= -1;

    return current_rotation;
  }

  public latent function playCameraScene(scene: RER_CameraScene, optional destroy_after: bool) {
    var current_rotation: EulerAngles;
    var current_position: Vector;

    // 1. we always start from the camera's position and its rotation
    // only if not relative, because relative position starts from (0, 0, 0)
    if (scene.position_type != RER_CameraPositionType_RELATIVE) {
      current_position = theCamera.GetCameraPosition();
    }

    current_rotation = theCamera.GetCameraRotation();

    // 2. then we move the camera there and start running
    this.TeleportWithRotation(current_position, current_rotation);
    this.Run();

    // 3. we start looping to animate the camera toward the scene goals
    this.blendToScene(scene, current_position, current_rotation);

    // 4. we start looping to blend back the camera to its original position
    this.blendToPlayer(scene, current_position, current_rotation);

    this.deactivationDuration = 2;
    this.Stop();

    if (destroy_after) {
      this.Destroy();
    }
  }

  private latent function blendToScene(scene: RER_CameraScene, out current_position: Vector, out current_rotation: EulerAngles) {
    var goal_rotation: EulerAngles;
    var time: float;

    time = theGame.GetEngineTimeAsSeconds();
    while (theGame.GetEngineTimeAsSeconds() - time < scene.duration) {

      // 1 we do the position & rotation blendings
      // 1.1 we do the position blending
      current_position += (scene.position - current_position) * scene.position_blending_ratio;

      // 1.2 we do the rotation blending
      goal_rotation = this.getRotation(scene, current_position);
      current_rotation.Roll += AngleNormalize180(goal_rotation.Roll - current_rotation.Roll) * scene.rotation_blending_ratio;
      current_rotation.Yaw += AngleNormalize180(goal_rotation.Yaw - current_rotation.Yaw) * scene.rotation_blending_ratio;
      current_rotation.Pitch += AngleNormalize180(goal_rotation.Pitch - current_rotation.Pitch) * scene.rotation_blending_ratio;

      // 2 we update the goal position using the velocity
      if (scene.velocity_type == RER_CameraVelocityType_ABSOLUTE) {
        scene.position += scene.velocity; // todo: use delta
      } else if (scene.velocity_type == RER_CameraVelocityType_FORWARD) {
        scene.position += VecNormalize(RotForward(current_rotation)) * scene.velocity;
      }
      else if (scene.velocity_type == RER_CameraVelocityType_RELATIVE) {
        scene.position += VecRotByAngleXY(scene.velocity, VecHeading(RotForward(current_rotation)));
      }

      // 3 we finally teleport the camera
      this.TeleportWithRotation(current_position, current_rotation);
      
      SleepOneFrame();
    }
  }

  private latent function blendToPlayer(scene: RER_CameraScene, out current_position: Vector, out current_rotation: EulerAngles) {
    var goal_rotation: EulerAngles;
    var goal_position: Vector;
    var time: float;

    time = theGame.GetEngineTimeAsSeconds();
    while (theGame.GetEngineTimeAsSeconds() - time < scene.duration) {
      goal_position = thePlayer.GetWorldPosition() + Vector(0, 0, 2) + VecNormalize(thePlayer.GetHeadingVector()) * -2;

      // 1 we do the position & rotation blendings
      // 1.1 we do the position blending
      current_position += (goal_position - current_position) * scene.position_blending_ratio;

      // 1.2 we do the rotation blending
      goal_rotation = thePlayer.GetWorldRotation();
      current_rotation.Roll += AngleNormalize180(goal_rotation.Roll - current_rotation.Roll) * MinF(scene.rotation_blending_ratio * 2, 1);
      current_rotation.Yaw += AngleNormalize180(goal_rotation.Yaw - current_rotation.Yaw) * MinF(scene.rotation_blending_ratio * 2, 1);
      current_rotation.Pitch += AngleNormalize180(goal_rotation.Pitch - current_rotation.Pitch) * MinF(scene.rotation_blending_ratio * 2, 1);

      // 3 we finally teleport the camera
      this.TeleportWithRotation(current_position, current_rotation);

      if (VecDistanceSquared(current_position, goal_position) < 1.5) {
        break;
      }
      
      SleepOneFrame();
    }
  }

}


latent function RER_getStaticCamera(): RER_StaticCamera {
  var template: CEntityTemplate;
  var camera: RER_StaticCamera;

  template = (CEntityTemplate)LoadResourceAsync("dlc\modtemplates\randomencounterreworkeddlc\data\rer_static_camera.w2ent", true);
  camera = (RER_StaticCamera)theGame.CreateEntity( template, thePlayer.GetWorldPosition(), thePlayer.GetWorldRotation() );

  return camera;
}
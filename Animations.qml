import QtQuick 2.15

Item {
    id: animations

    // Targets for animations
    property var bigCircle
    property var bigCircleEffect
    property var goalCircle
    property var goalCircleEffect
    property var taskListView
    property var subGoalsList

    // Task scroll animation
    property NumberAnimation taskScrollAnimation: NumberAnimation {
        target: animations.taskListView
        property: "contentY"
        duration: 300
        easing.type: Easing.OutCubic
    }

    // SubGoal scroll animation
    property NumberAnimation scrollAnimation: NumberAnimation {
        target: animations.subGoalsList
        property: "contentX"
        duration: 400
        easing.type: Easing.OutCubic
    }

    // Unified pulse animation (when all tasks completed)
    property ParallelAnimation unifiedPulseAnimation: ParallelAnimation {
        SequentialAnimation {
            ParallelAnimation {
                ScaleAnimator {
                    target: animations.bigCircle
                    from: 1.0
                    to: 1.02
                    duration: 600
                    easing.type: Easing.OutCubic
                }
                NumberAnimation {
                    target: animations.bigCircleEffect
                    property: "shadowBlur"
                    from: 2.0
                    to: 1.0
                    duration: 600
                    easing.type: Easing.OutCubic
                }
                NumberAnimation {
                    target: animations.bigCircleEffect
                    property: "shadowOpacity"
                    from: 0.4
                    to: 0.8
                    duration: 600
                    easing.type: Easing.OutCubic
                }
                NumberAnimation {
                    target: animations.bigCircleEffect
                    property: "shadowVerticalOffset"
                    from: 5
                    to: 8
                    duration: 600
                    easing.type: Easing.OutCubic
                }
            }
            ParallelAnimation {
                ScaleAnimator {
                    target: animations.bigCircle
                    from: 1.02
                    to: 1.0
                    duration: 1600
                    easing.type: Easing.OutCubic
                }
                NumberAnimation {
                    target: animations.bigCircleEffect
                    property: "shadowBlur"
                    from: 1.0
                    to: 2.0
                    duration: 1600
                    easing.type: Easing.OutBack
                }
                NumberAnimation {
                    target: animations.bigCircleEffect
                    property: "shadowOpacity"
                    from: 0.8
                    to: 0.4
                    duration: 1600
                    easing.type: Easing.OutBack
                }
                NumberAnimation {
                    target: animations.bigCircleEffect
                    property: "shadowVerticalOffset"
                    from: 8
                    to: 5
                    duration: 1600
                    easing.type: Easing.OutBack
                }
            }
        }
        SequentialAnimation {
            PauseAnimation { duration: 200 }
            ParallelAnimation {
                ScaleAnimator {
                    target: animations.goalCircle
                    from: 1.0
                    to: 1.01
                    duration: 700
                    easing.type: Easing.OutCubic
                }
                NumberAnimation {
                    target: animations.goalCircleEffect
                    property: "shadowBlur"
                    from: 1.5
                    to: 1.0
                    duration: 700
                    easing.type: Easing.OutCubic
                }
                NumberAnimation {
                    target: animations.goalCircleEffect
                    property: "shadowOpacity"
                    from: 0.5
                    to: 0.9
                    duration: 700
                    easing.type: Easing.OutCubic
                }
                NumberAnimation {
                    target: animations.goalCircleEffect
                    property: "shadowVerticalOffset"
                    from: 5
                    to: 10
                    duration: 700
                    easing.type: Easing.OutCubic
                }
            }
            ParallelAnimation {
                ScaleAnimator {
                    target: animations.goalCircle
                    from: 1.01
                    to: 1.0
                    duration: 2000
                    easing.type: Easing.OutBack
                }
                NumberAnimation {
                    target: animations.goalCircleEffect
                    property: "shadowBlur"
                    from: 1.0
                    to: 1.5
                    duration: 2000
                    easing.type: Easing.OutBack
                }
                NumberAnimation {
                    target: animations.goalCircleEffect
                    property: "shadowOpacity"
                    from: 0.9
                    to: 0.5
                    duration: 2000
                    easing.type: Easing.OutBack
                }
                NumberAnimation {
                    target: animations.goalCircleEffect
                    property: "shadowVerticalOffset"
                    from: 10
                    to: 5
                    duration: 2000
                    easing.type: Easing.OutBack
                }
            }
        }
    }

    // Big circle only animation (when not all tasks completed)
    property SequentialAnimation bigCircleOnlyAnimation: SequentialAnimation {
        ParallelAnimation {
            ScaleAnimator {
                target: animations.bigCircle
                from: 1.0
                to: 1.02
                duration: 600
                easing.type: Easing.OutCubic
            }
            NumberAnimation {
                target: animations.bigCircleEffect
                property: "shadowBlur"
                from: 2.0
                to: 1.0
                duration: 600
                easing.type: Easing.OutCubic
            }
            NumberAnimation {
                target: animations.bigCircleEffect
                property: "shadowOpacity"
                from: 0.4
                to: 0.8
                duration: 600
                easing.type: Easing.OutCubic
            }
            NumberAnimation {
                target: animations.bigCircleEffect
                property: "shadowVerticalOffset"
                from: 5
                to: 8
                duration: 600
                easing.type: Easing.OutCubic
            }
        }
        ParallelAnimation {
            ScaleAnimator {
                target: animations.bigCircle
                from: 1.02
                to: 1.0
                duration: 1600
                easing.type: Easing.OutCubic
            }
            NumberAnimation {
                target: animations.bigCircleEffect
                property: "shadowBlur"
                from: 1.0
                to: 2.0
                duration: 1600
                easing.type: Easing.OutBack
            }
            NumberAnimation {
                target: animations.bigCircleEffect
                property: "shadowOpacity"
                from: 0.8
                to: 0.4
                duration: 1600
                easing.type: Easing.OutBack
            }
            NumberAnimation {
                target: animations.bigCircleEffect
                property: "shadowVerticalOffset"
                from: 8
                to: 5
                duration: 1600
                easing.type: Easing.OutBack
            }
        }
    }
}

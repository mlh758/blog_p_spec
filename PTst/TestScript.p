spec Liveness observes  eInput, eDone {
    var lastRequest: int;
    start cold state Init {
        on eInput do (input: InputMessage) {
            HandleInput(input);
            goto AwaitingValidation;
        }
    }

    hot state AwaitingValidation {
        on eInput do HandleInput;
        on eDone do (id: int) {
            if (id == lastRequest) {
                goto Init;
            }
        }
    }

    fun HandleInput(input: InputMessage) {
        lastRequest = input.id;
    }
}

test ReactComponent [main=User]: assert Liveness in {User,Component,Server};
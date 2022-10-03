type InputMessage = (id: int, maybeValid: bool);
type ValidationResult = (id: int, valid: bool);
type ValidationRequest = (comp: machine, id: int);
event eInput: InputMessage;
event eValidationRequest: ValidationRequest;
event eValidationResult: ValidationResult;
event eValidationError;

machine User {
  var component: Component;
  var reqId: int;
  start state Init {
    entry {
      component = new Component();
      reqId = 0;
      goto Typing;
    }
  }

  state Typing {
    on null do {
      var maybeValid: bool;
      // $$ means arbitrarily choose one or the other but eventually try both branches
      if($$) {
        maybeValid = true;
      } else {
        maybeValid = false;
      }
      send component, eInput, (id = reqId, maybeValid = maybeValid);
      reqId = reqId + 1;
    }
  }
}

machine Component {
  var server: Server;
  var currentInput: InputMessage;
  start state Init {
    entry  {
      server = new Server();
      currentInput = (id = -1, maybeValid = false);
      goto Waiting;
    }
  }
  state Waiting {
    on eInput do (input: InputMessage) {
      if (input.maybeValid) {
        send server, eValidationRequest, (comp = this, id = input.id);
        goto Validating;
      }
    }
  }
  state Validating {
    on eValidationResult do (result: ValidationResult) {
      if (result.valid) {
        goto Valid;
      } else {
        goto Invalid;
      }
    }
    on eValidationError do {
      goto WaitingManualBic;
    }
    on eInput do {
      goto Waiting;
    }
  }
  state Valid {
    ignore eInput;
  }
  state Invalid {
    ignore eInput;
  }
  state WaitingManualBic {
    on eInput do (input: InputMessage) {
      if (input.maybeValid) {
        goto LocalValidationSuccess;
      }
    }
  }
  state LocalValidationSuccess {
    ignore eInput;
  }
}

machine Server {
  start state Serving {
    on eValidationRequest do (req: ValidationRequest) {
      if ($) {
        if ($) {
          send req.comp, eValidationResult, (id = req.id, valid = true);
        } else {
          send req.comp, eValidationResult, (id = req.id, valid = false);
        }
      } else {
        send req.comp, eValidationError;
      }
    }
  }
}
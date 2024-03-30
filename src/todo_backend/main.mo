import Map "mo:base/HashMap";
import Hash "mo:base/Hash";
import Nat64 "mo:base/Nat64";
import Iter "mo:base/Iter";
import Text "mo:base/Text";
import Timer "mo:base/Timer";
import Debug "mo:base/Debug";
import { print } "mo:base/Debug";
import { abs } "mo:base/Int";
import Nat "mo:base/Nat";
import Time "mo:base/Time";




// Define the actor
actor {

  type ToDo = {
    description: Text;
    completed: Bool;
    duration: Text;
  };

  func natHash(n : Nat) : Hash.Hash { 
    Text.hash(Nat.toText(n))
  };

  var todos = Map.HashMap<Nat, ToDo>(0, Nat.equal, natHash);
  var nextId : Nat = 0;

  public query func getTodos() : async [ToDo] {
    Iter.toArray(todos.vals());
  };

  public func addToDo(description: Text, duration: Text) : async Nat {
    let id = nextId;
    todos.put(id, {description=description; completed = false; duration=duration});
    nextId += 1;
    id //return id;
  };

  public func completeToDo(id: Nat) : async () {
    ignore do ? {
      let description = todos.get(id)!.description;
      todos.put(id, {description; completed = true; duration="--------"});
    }
  };


  public func remind() : async () {
    print("Time is up!");
  };

  system func timer(setGlobalTimer : Nat64 -> ()) : async () {
  let next = Nat64.fromIntWrap(Time.now()) + 300_000_000_000; //every 300 seconds => 5 minutes
  setGlobalTimer(next); // absolute time in nanoseconds
  Debug.print "5 minutes has passed!";
};

  public query func showToDos () : async Text {
    var output: Text = "\n____TO-DOs____DURATION";
    for (todo: ToDo in todos.vals()){
      output #= "\n" # todo.description;
      if(todo.completed) {output #= " +\t"};
    };
    output # "\n"
  };

  public func clearCompleted() : async () {
    todos := Map.mapFilter<Nat, ToDo, ToDo>(todos, Nat.equal, natHash,
      func(_, todo) {if (todo.completed) null else ?todo});
  };

};
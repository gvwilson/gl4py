import gleam/io

// mccole: icecream_type
type Flavor {
  Chocolate
  Vanilla
  Strawberry
}

type Container {
  Cone
  Cup
}

type IceCream {
  IceCream(flavor: Flavor, container: Container)
}
// mccole: /icecream_type

pub fn main() {
  let choc_cone = IceCream(flavor: Chocolate, container: Cone)
  let van_cup = IceCream(flavor: Vanilla, container: Cup)
  let straw_cone = IceCream(flavor: Strawberry, container: Cone)

  io.println("chocolate cone is " <> display(choc_cone))
  io.println("vanilla cone is " <> display(van_cup))
  io.println("strawberry cone is " <> display(straw_cone))
}

// mccole: display_fn
fn display(item: IceCream) -> String {
  flavor_string(item.flavor) <> " in a " <> container_string(item.container)
}
// mccole: /display_fn

fn flavor_string(flavor: Flavor) -> String {
  case flavor {
    Chocolate -> "Chocolate"
    Vanilla -> "Vanilla"
    Strawberry -> "Strawberry"
  }
}

fn container_string(container: Container) -> String {
  case container {
    Cone -> "cone"
    Cup -> "cup"
  }
}

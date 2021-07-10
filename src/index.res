@val external document: {..} = "document"
@val external window: {..} = "window"
@val external setInterval: (unit => unit, int) => int = "setInterval"
@val external clearInterval: int => unit = "clearInterval"
@val external setTimeout: (unit => unit, int) => int = "setTimeout"
@val external clearTimeout: int => unit = "clearTimeout"

module Post = {
  type t = {
    title: string,
    author: string,
    text: array<string>,
  }

  let make = (~title, ~author, ~text) => {title: title, author: author, text: text}
  let title = t => t.title
  let author = t => t.author
  let text = t => t.text
}

let posts = [
  Post.make(
    ~title="The Razor's Edge",
    ~author="W. Somerset Maugham",
    ~text=[
      "\"I couldn't go back now. I'm on the threshold. I see vast lands of the spirit stretching out before me,
    beckoning, and I'm eager to travel them.\"",
      "\"What do you expect to find in them?\"",
      "\"The answers to my questions. I want to make up my mind whether God is or God is not. I want to find out why
    evil exists. I want to know whether I have an immortal soul or whether when I die it's the end.\"",
    ],
  ),
  Post.make(
    ~title="Ship of Destiny",
    ~author="Robin Hobb",
    ~text=[
      "He suddenly recalled a callow boy telling his tutor that he dreaded the sea voyage home, because he would have
        to be among common men rather than thoughtful acolytes like himself. What had he said to Berandol?",
      "\"Good enough men, but not like us.\"",
      "Then, he had despised the sort of life where simply getting from day to day prevented a man from ever taking
        stock of himself. Berandol had hinted to him then that a time out in the world might change his image of folk
        who labored every day for their bread. Had it? Or had it changed his image of acolytes who spent so much time in
        self-examination that they never truly experienced life?",
    ],
  ),
  Post.make(
    ~title="A Guide for the Perplexed: Conversations with Paul Cronin",
    ~author="Werner Herzog",
    ~text=[
      "Our culture today, especially television, infantilises us. The indignity of it kills our imagination. May I propose a Herzog dictum? Those who read own the world. Those who watch television lose it. Sitting at home on your own, in front of the screen, is a very different experience from being in the communal spaces of the world, those centres of collective dreaming. Television creates loneliness. This is why sitcoms have added laughter tracks which try to cheat you out of your solitude. Television is a reflection of the world in which we live, designed to appeal to the lowest common denominator. It kills spontaneous imagination and destroys our ability to entertain ourselves, painfully erasing our patience and sensitivity to significant detail.",
    ],
  ),
]

/*
 helper function to interact with JS Dom
*/

let makeDiv = () => document["createElement"]("div")

let makeScaledHeading = tag => document["createElement"](tag)

let makePara = () => document["createElement"]("p")

let makeButton = () => document["createElement"]("button")

let makeSpecialElement = tag => document["createElement"](tag)

let makeTextNode = text => document["createTextNode"](text)

let addClass = (element, className) => {
  element["classList"]["add"](className)
  element
}

let addId = (element, idName) => {
  element["id"] = idName
  element
}

let addText = (element, text) => {
  element["innerText"] = text
  element
}

let toString = index => Belt.Int.toString(index)

let getElementById = id => document["getElementById"](id)

/*
 components
*/

let makeDeleteNotificationComponent = (index, title, author, deletedPost) => {
  let timeOutId = setTimeout(() => {
    let element = getElementById(`block-${index->toString}`)
    document["body"]["removeChild"](element)
  }, 10000)

  let div = makeDiv()->addId(`block-${index->toString}`)->addClass("post-deleted")->addClass("pt-1")
  let para = makePara()->addClass("text-center")->addText("This post from ")

  let specialElement = makeSpecialElement("em")->addText(`${title} by ${author}`)

  let _ = para["appendChild"](specialElement)

  let _ = para["appendChild"](makeTextNode(" will be permanently removed in 10 seconds."))

  let _ = div["appendChild"](para)

  let buttonsDiv = makeDiv()->addClass("flex-center")
  let restoreButton =
    makeButton()
    ->addId(`block-restore-${index->toString}`)
    ->addClass("button")
    ->addClass("button-warning")
    ->addClass("mr-1")
    ->addText("Restore")
  let _ = restoreButton["addEventListener"]("click", () => {
    let element = getElementById(`block-${index->toString}`)
    clearTimeout(timeOutId)
    document["body"]["replaceChild"](deletedPost, element)
  })

  let immediateDeleteButton =
    makeButton()
    ->addId(`block-delete-immediate-${index->toString}`)
    ->addClass("button")
    ->addClass("button-danger")
    ->addText("Delete Immediately")
  let _ = immediateDeleteButton["addEventListener"]("click", () => {
    let element = getElementById(`block-${index->toString}`)
    clearTimeout(timeOutId)
    document["body"]["removeChild"](element)
  })

  let _ = buttonsDiv["appendChild"](restoreButton)
  let _ = buttonsDiv["appendChild"](immediateDeleteButton)
  let _ = div["appendChild"](buttonsDiv)

  let progressBar = makeDiv()->addClass("post-deleted-progress")
  let _ = div["appendChild"](progressBar)
  div
}

let makePostComponent = (index, post: Post.t) => {
  let div = makeDiv()->addId(`block-${index->toString}`)->addClass("post")
  let heading = makeScaledHeading("h2")->addText(post.title)
  let subHeading = makeScaledHeading("h3")->addText(post.author)
  let _ = div["appendChild"](heading)
  let _ = div["appendChild"](subHeading)

  post.text->Belt.Array.forEach(text => {
    let para = makePara()->addClass("post-text")->addText(text)
    div["appendChild"](para)
  })

  let deleteButton =
    makeButton()
    ->addId(`block-delete-${index->toString}`)
    ->addClass("button")
    ->addClass("button-danger")
    ->addText("Remove this post")
  let _ = deleteButton["addEventListener"]("click", () => {
    let postElement = getElementById(`block-${index->toString}`)
    let _ = document["body"]["replaceChild"](
      makeDeleteNotificationComponent(index, post.title, post.author, postElement),
      postElement,
    )
  })

  let _ = div["appendChild"](deleteButton)
  div
}

let onLoadRenderPosts = posts => {
  posts->Belt.Array.forEachWithIndex((index, post) =>
    document["body"]["appendChild"](makePostComponent(index, post))
  )
}

onLoadRenderPosts(posts)

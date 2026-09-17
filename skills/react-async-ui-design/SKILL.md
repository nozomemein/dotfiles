---

name: react-async-ui-design
description: Review and design asynchronous React UI using Suspense, Transitions, useDeferredValue, and useOptimistic. Use when implementing or reviewing async interactions, loading and pending states, Suspense boundaries, startTransition usage, optimistic UI, deferred rendering, navigation, form actions, or component APIs. Focus on the UI guarantees required by each interaction rather than mechanically applying React APIs.

---

# React Async UI Design

Design and review asynchronous React UI by reasoning about **UI guarantees and constraints**, not by choosing APIs first.

The goal is to describe what the UI requires and leave scheduling and rendering decisions to React whenever possible.

## Core model

For each interaction, determine:

1. What user intent initiated the update?
2. Must the update be presented immediately?
3. Which UI regions must appear together?
4. Which regions may wait independently?
5. May some UI temporarily remain stale?
6. Should some UI appear before the underlying work finishes?
7. Does pending state represent application state or React rendering state?

Use these answers to choose between normal updates, Transitions, Suspense, `useDeferredValue`, and `useOptimistic`.

```text
User Intent
    │
    ▼
State Change
    │
    ├─ must be reflected immediately
    │      └─ urgent update
    │
    └─ may be presented later
           └─ Transition
                │
                ├─ Suspense
                │    └─ UI independence
                │
                ├─ useDeferredValue
                │    └─ temporary stale UI
                │
                └─ useOptimistic
                     └─ immediate speculative UI
```

Do not treat this diagram as a mandatory API sequence. Several mechanisms may apply to the same interaction.

# 1. Classify updates before implementing them

For every state update, first ask:

> Does this change need to become visible immediately?

## Urgent updates

Use a normal update when React needs to synchronize with something that has already happened.

Common examples:

* controlled input values
* direct user input
* browser or DOM state synchronization
* external store synchronization

```tsx
<input
  value={value}
  onChange={(event) => {
    setValue(event.target.value);
  }}
/>
```

Do not mechanically wrap these updates in `startTransition`.

The relevant external state has already changed. React needs to catch up immediately.

## Transition updates

Treat an update as a Transition candidate when a user action creates a **new application state** that does not need immediate presentation.

Common examples:

* navigation
* tab switching
* filtering
* form submission
* save operations
* deletion
* adding an item
* changing application state after an action

```tsx
const [isPending, startTransition] = useTransition();

function handleAction() {
  startTransition(async () => {
    await action();
  });
}
```

Interpret a Transition as:

> This update should eventually become visible, but immediate presentation is not required.

Do not describe `startTransition` merely as a performance optimization or as "making an update low priority."

Prefer reasoning in terms of the guarantee being relaxed.

```text
urgent
= React should reflect this state immediately

transition
= React may delay presentation while preserving a better intermediate UI
```

# 2. Design Suspense boundaries around UI independence

Do not place a Suspense boundary merely because a component performs asynchronous work.

Ask:

> If this subtree suspends, should the surrounding UI remain visible?

If yes, the subtree is a candidate for an independent Suspense boundary.

```tsx
<Header />

<Suspense fallback={<ResultsSkeleton />}>
  <SearchResults />
</Suspense>
```

This expresses a UI relationship:

```text
Header
  └─ may remain visible independently

SearchResults
  └─ may wait without hiding Header
```

Treat Suspense boundaries as **boundaries of UI independence**.

Avoid reasoning like:

```text
This component fetches data
→ wrap it in Suspense
```

Prefer:

```text
This region may wait independently
→ give it its own Suspense boundary
```

When reviewing Suspense placement, consider the user-visible reveal behavior rather than component or module boundaries.

# 3. Use `useDeferredValue` when stale UI is temporarily acceptable

Ask:

> Can one part of the UI temporarily display an older value while another part reflects the latest value?

If yes, consider `useDeferredValue`.

```tsx
const deferredQuery = useDeferredValue(query);

<SearchResults query={deferredQuery} />
```

A valid temporary state might be:

```text
input value   = "react"
search result = "rea"
```

The design decision is:

> Immediate responsiveness of the input matters more than immediate consistency of the dependent UI.

Typical candidates include:

* search results
* expensive filtering
* large lists
* previews
* charts
* visualizations
* expensive derived UI

Do not treat `useDeferredValue` as debounce.

It does not mean:

> Wait a fixed amount of time before updating.

It means:

> This dependent UI may lag behind the latest state.

# 4. Use `useOptimistic` when UI should appear before completion

Ask:

> Should the effect of the user's action become visible before the underlying asynchronous work completes?

If yes, consider `useOptimistic`.

Typical examples:

* adding an item
* liking or favoriting
* deleting an item
* posting a comment
* updating a cart
* immediately reflecting a state-changing action

```tsx
const [optimisticItems, addOptimisticItem] =
  useOptimistic(items, reducer);
```

Model the interaction as:

```text
Action
  │
  ▼
Transition
  │
  ├──────── asynchronous work
  │
  └─ optimistic state
         │
         ▼
      immediate UI
```

Do not treat `useOptimistic` only as a server mutation utility.

Its UI-level meaning is:

> This result should be visible immediately even though the surrounding interaction has not completed.

# 5. Question manual loading state

When reviewing code, investigate state such as:

```tsx
const [isLoading, setIsLoading] = useState(false);
const [isSubmitting, setIsSubmitting] = useState(false);
const [isNavigating, setIsNavigating] = useState(false);
```

Do not automatically remove it.

First determine what the state represents.

If it only duplicates the lifecycle of a Transition, consider:

```text
manual isLoading
      ↓
Transition isPending
```

If it only controls rendering while a subtree waits, consider:

```text
manual loading branch
      ↓
Suspense
```

Avoid storing state that React already models.

## Preserve genuine application state

Manual pending state is appropriate when it represents domain state independent of React rendering.

Examples:

* a backend job is running
* an upload is processing
* an order is pending
* a workflow is waiting
* a task is queued

These states should not be replaced with `isPending`.

Distinguish:

```text
React interaction state
vs
application/domain state
```

# 6. Prefer intent-oriented component APIs when appropriate

When reviewing component APIs, determine whether a component is exposing low-level DOM events even though it owns a higher-level application interaction.

For example:

```tsx
<Button onClick={save}>
  Save
</Button>
```

may be appropriate for a generic UI primitive.

For an application component that owns asynchronous action behavior, consider an intent-oriented API:

```tsx
<Button action={save}>
  Save
</Button>
```

The component may then own:

* Transition creation
* pending state
* repeated-action prevention
* progress indication
* accessibility state

Example:

```tsx
function Button({
  action,
  children,
}: {
  action: () => Promise<void>;
  children: React.ReactNode;
}) {
  const [isPending, startTransition] = useTransition();

  return (
    <button
      disabled={isPending}
      aria-busy={isPending}
      onClick={() => {
        startTransition(async () => {
          await action();
        });
      }}
    >
      {isPending ? "Saving..." : children}
    </button>
  );
}
```

Prefer APIs that express application intent when the component owns application semantics.

Examples:

```text
action
saveAction
deleteAction
submitAction
```

Do not mechanically replace:

```text
onClick
onSubmit
onChange
```

Generic primitives should continue to expose low-level event APIs when that is their proper abstraction.

# 7. Model the full interaction

Do not define pending state only as:

> A Promise is still running.

A user interaction may continue after the original asynchronous function resolves.

For example:

```text
User Action
    │
    ▼
Transition Starts
    │
    ├─ Mutation
    ├─ State Update
    ├─ Render
    └─ Suspense
         │
         ▼
      UI Ready
```

The UI may still be pending because rendering triggered by the action is suspended.

Prefer pending state that represents the complete user interaction when that better matches the user experience.

# Review workflow

When reviewing an asynchronous interaction, follow this order.

## Step 1: Identify the intent

Determine what the user is trying to do.

Examples:

```text
type text
change tab
navigate
save
delete
submit
filter
add item
```

Do not start by inspecting individual hooks.

## Step 2: Identify state changes

Trace which state changes belong to the interaction.

Separate:

* synchronization updates
* application state changes
* server/domain state
* temporary rendering state

## Step 3: Determine urgency

For each update ask:

> Must this state be presented immediately?

If yes, keep it urgent.

Otherwise, consider a Transition.

## Step 4: Determine reveal boundaries

Ask:

> If part of this interaction waits, which UI should remain visible?

Use the answer to evaluate Suspense boundaries.

## Step 5: Determine acceptable staleness

Ask:

> May any UI remain temporarily based on an older value?

If yes, evaluate `useDeferredValue`.

## Step 6: Determine optimistic presentation

Ask:

> Should anything appear before the operation is confirmed or completed?

If yes, evaluate `useOptimistic`.

## Step 7: Review ownership

Determine which component should own:

* the action
* the Transition
* pending presentation
* optimistic state
* Suspense boundary

Keep interaction behavior close to the semantic owner when practical.

# Common smells

Flag these patterns for investigation. Do not automatically rewrite them.

## Manual loading around every async operation

```tsx
async function handleSubmit() {
  setLoading(true);

  try {
    await submit();
    await refetch();
  } finally {
    setLoading(false);
  }
}
```

Ask whether the entire interaction is better modeled as a Transition.

## Suspense chosen by implementation structure

Weak reasoning:

```text
This component fetches data.
Therefore it needs Suspense.
```

Better reasoning:

```text
This UI region should be able to wait independently.
Therefore it needs a Suspense boundary.
```

## Every update wrapped in `startTransition`

Do not convert every update into a Transition.

Controlled inputs and other synchronization updates generally need to remain urgent.

## Transition described as debounce

Do not interpret Transition as:

> Execute this later.

Interpret it as:

> Immediate presentation of this render is not required.

## Duplicated pending state

Investigate state such as:

```text
isLoading
isSubmitting
isSaving
isNavigating
```

Determine whether it represents:

```text
domain state
```

or merely:

```text
React interaction state
```

## Loading state owned far from the interaction

If a child initiates an action while a distant parent manually manages its pending state, check whether interaction ownership can be moved closer to the component that owns the action.

## Generic event APIs carrying application semantics

If application components repeatedly expose:

```tsx
onClick={() => save()}
```

consider whether an explicit action API would represent the abstraction more accurately.

Do not apply this recommendation to generic UI primitives.

# Review output

When proposing a change, explain the **UI constraint or guarantee** behind it.

Prefer:

> This update does not require immediate presentation, so model it as a Transition.

Avoid:

> Use `startTransition` because it is faster.

Prefer:

> These regions should be independently revealable, so separate their Suspense boundaries.

Avoid:

> This component fetches data, so wrap it in Suspense.

Prefer:

> Search results may temporarily lag behind the input, so `useDeferredValue` matches the desired UI behavior.

Avoid:

> `useDeferredValue` improves performance.

Prefer:

> The new item should appear before the action completes, so optimistic state is appropriate.

Avoid:

> Use `useOptimistic` because this is a mutation.

# Final principle

Prefer this mental model:

```text
Application
    │
    └─ declares intent and UI constraints
               │
               ▼
             React
               │
       ┌───────┼────────┐
       ▼       ▼        ▼
   Scheduling Suspense Rendering
               │
               ▼
              UI
```

over:

```text
Application
    │
    ├─ manually tracks loading
    ├─ manually controls rendering timing
    ├─ manually switches placeholders
    └─ manually coordinates every async phase
```

The objective is not to maximize usage of Suspense, Transition, `useDeferredValue`, or `useOptimistic`.

The objective is to express enough about the desired UI behavior that React can coordinate asynchronous rendering without unnecessary manual control.


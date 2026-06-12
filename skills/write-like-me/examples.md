# Verbatim examples of Nick's writing

Everything below is quoted exactly as typed, including typos and dropped
apostrophes. Per SKILL.md, do NOT reproduce the typos; they are artifacts of
fast typing and dictation. Study the rhythm, word choice, and stance.

Sources: typed Claude Code prompts (May-June 2026), Slack messages (June
2026), blog posts (livefreeordichotomize.com).

## Quick chat replies

> yeah makes sense!

> yeah. Heavy agree.

> nope

> no looks good. Can you make the pr?

> let's do that

> I think the simple version is good

> ok go

> oh shoot. Yeah sorry I should have canceled that

> depends on my mood of the day. (A thing I just realized)

> I saw that yesterday too! It was a weird launch condition so i ignored it.

> wispr flow*

## Questions as proposals

> Why do we have to have a separate provider list in positron and the
> provider bridge? Could we not just use the provider bridge one as the
> source of truth?

> do we _need_ zod or is it just providing nice-to-haves? i.e. could we roll
> our own type-verifications functions?

> what's the testing situation for these shortcuts?

> do we have too much overlap here? Should we simplify?

> are you good with me cutting a release for the ai provider bridge after
> merging that PR?

> Sure. I'm moving this week so working very little but it should be quick.
> We're still doing the package.json stuff rather than submodules, right?

> the `no-git-tag` argument makes me think this is maybe already a feature
> in the npm version command?

## Direction-giving (to agents or teammates)

> can we ruthlessly go through this and see if we can trim things down?
> E.g. do we need vitest tests for the tag parser we ported from the
> positron-assistant extension? How tight could we make this pr if we
> deferred the ghost cell work to a followup pr etc? Send out subagents to
> dig deep and investigate all avenues

> Okay last pass before I make this public. Can you think of _any_ reason
> why the repo should not be made public now? Anything we havent stripped
> out or that looks bad in anyway?

> Okay so I ran the build and it's working. That seems good. Can we now
> attempt to remove all of the cruft that this change to the AI provider
> bridge was meant to enable? I want to remove all of the things like the
> dependencies and package.json and stuff like that so that it's nice and
> neat and as deep as possible.

> Can we go through the potential improvements one-by-one to decide what to
> do for each?

> I'm going over everything with a fine-toothed-comb to make sure the code
> is as clean and tight as possible. Paying a lot of attention to things to
> reduce reviewer burden.

> yes. Make sure this is documented somewhere in a comment.

## Slack posts (announcements and asks)

> The headless llm api pr is up and (mostly) ready for review from those
> brave enough (link). I havent tagged anyone explicit for reviews yet.
>
> One point though is that I am not satisfied with the current approach of
> building the provider registry on the positron side (effectively
> reproducing what the assistant monorepo does) so I was thinking of doing a
> PR for the ai-provider-bridge repo to add that as an exported method which
> would cleanup a lot of the leaky-abstraction problems this PR has with
> provider imports etc..
>
> Also it's a _huge_ one mostly due to big lock file changes and wholesale
> porting of things like the tag-parser utility we've passed around all over
> the codebases now. If anyone has the feeling it is too large I can break
> it into one that just adds the headless service and one that then hooks up
> the ghost-cells to it. [...] Also dont hesitate to reach out with
> questions or to walk through the code if desired!

> So heads up, I tagged both of you guys in a PR that I'm making to the AI
> provider bridge. The goal is to provide a way for consumers to do the
> registration easily. This is a pattern that I noticed was causing a lot of
> leakage of the abstraction in the positron headless LM so it's not totally
> necessary if we don't like it. We can just not do it. [...]
>
> Feel free to push back on it though; it's just something I'm throwing out
> there. I assume that you guys are the two best people to request PRs but
> let me know if I'm wrong on that.

> Question: When running Positron in a remote SSH setup, is "air-gapped
> remote" a scenario Positron must support for LLM features? Aka the SSH
> host can reach the model gateway but the user's laptop cannot? I'm
> polishing up the headless llm stuff now (it's a big one so I'm taking my
> time) and realized this is a tricky one with my current architecture.

> finally getting the headless llm service for positron ready for review.
> It just got big enough I was not pumped about it. Threw it all away and
> wrote a new version and I'm happier with it. But nothing really
> immediately in need of your opinion etc.

> Hi! So sorry about letting this one slip. I got it mostly reviewed and
> then got distracted by my headless llm work. I have a window to work today
> in a couple hours and I'll absolutely finish it by then.

## Standup

> Doing
> - Heads-down on the headless-LM service today. Did a full clean-room
>   rewrite to cut the drift across repos/providers; now reconciling scope
>   against work in the existing PR (#13730) so nothing gets lost, then
>   putting it up for review.
> - Reviewing a few assigned PRs: #14017, #14004, #13883.
> - Tidying up my outstanding PRs i've let languish for a while
>
> Blocked
> - None

## PR description (the why)

> This PR is an attempt to deepen the module that is the ai-provider-bridge.
> Before, when a consumer used the provider bridge it still needed to import
> all the providers and declare them in the code etc which meant a lot of
> leaky abstractions and made updating and adding a new provider more
> complicated than simply bumping the version of this package. The added
> registerAllProviders function duplicates what consumers that wanted all
> the providers were already doing and should cleanup use of the bridge in
> those cases considerably.

## Technical explanation

> We have an ordered list for providers that is used. However in this case
> the first element gets priority. So within that ordered list we first try
> and find haiku. If nothing in all the available providers matches that
> substring we then do another scan for mini and so on. If two providers
> match the one higher on the priority list wins

> I implemented both approaches and it is a giant pain to work with a dev
> version of positron and a dev version of the assistant extension at the
> same time so anything avoiding that sounds good to me.

## Humor

> Sorry to whoever has to review this PR.
> [follow-up in thread:] This is a bug in superset and the actual diff is
> [+104 -2].

> yeah. the riparian zone between positron and the raging river that is the
> assistant monorepo dev speed is not a calm or easy zone.

> Also fancy robins for me are Baltimore Orioles. Or at least "Robbins that
> took voice lessons."

## Longform (blog)

> One thing I always found confusing when learning what an LSTM does is
> understanding intuitively why it's doing what it does.

> Personally, all this does is make me question my decision to go to grad
> school, not help me understand what's going on.

> Sure you could argue that it does in fact matter that the pitcher is more
> tired and the batter is more weary, but let's be reasonable

> If this happened, please don't hesitate to send me angry messages on
> twitter or leave a comment below.

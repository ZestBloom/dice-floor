# dice

Alice loads the dice with 6 NFTs in order. Each roll will release 1 NFT to the roller. Variant rules apply.

## quickstart

commands
```bash
git clone git@github.com:ZestBloom/dice.git
cd dice
source np.sh 
run
```

*requires devnet*

output
```json
{"info":66944916}
```

## how does it work

NP provides a nonintrusive wrapper allowing apps to be configurable before deployment and created on the fly without incurring global storage.   
Connect to the constructor and receive an app id.   
Activate the app by paying for deployment and storage cost. 
After activation, your RApp takes control.

## how to activate my app

In your the frontend of your NPR included Contractee participation. Currently, a placeholder fee is required for activation. Later an appropriate fee amount will be used.

```js
ctc = acc.contract(backend, id)
backend.Contractee(ctc, {})
```

## terms

- NP - Nash Protocol
- RAap - Reach App
- NPR - NP Reach App
- Activation - Hand off between constructor and contractee require fee to pay for deployment and storage cost incurred by constructor

## dependencies

- Reach development environment (reach compiler)
- sed - stream editor
- grep - pattern matching
- curl - request remote resource



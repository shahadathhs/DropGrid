'use client'

import { useEffect, useRef, useState } from 'react'
import { ChevronRight, Mail, ShieldCheck, Sparkles, UserRound } from 'lucide-react'
import { useApp } from '@/lib/app'
import { Btn, Eyebrow, Screen, TopBar } from '@/components/ui'

export function AccountScreen() {
  const { go } = useApp()
  return (
    <Screen className="screen-auth">
      <TopBar title="Your DropGrid" />
      <div className="auth-intro">
        <div className="auth-orb">
          <Sparkles size={22} />
        </div>
        <Eyebrow>Play your way</Eyebrow>
        <h2>
          Keep your
          <br />
          <em>progress.</em>
        </h2>
        <p>Save your stats, climb the leaderboard, and pick up every run where you left it.</p>
      </div>
      <div className="stack">
        <Btn icon={Mail} onClick={() => go('email')}>
          Continue with email
        </Btn>
        <Btn variant="text" onClick={() => go('menu')}>
          Not now
        </Btn>
      </div>
      <p className="legal-note">No password needed. We’ll send a one-time code to verify you.</p>
    </Screen>
  )
}

export function EmailScreen() {
  const { go, email, update } = useApp()
  const valid = /.+@.+\..+/.test(email)

  return (
    <Screen className="screen-auth">
      <TopBar title="Sign in" />
      <div className="form-copy">
        <Eyebrow>Step 1 / 2</Eyebrow>
        <h2>
          Where should
          <br />
          we send it?
        </h2>
        <p>Enter your email and we’ll send a secure one-time code.</p>
      </div>
      <label className="field-label" htmlFor="email">
        Email address
      </label>
      <div className="input-shell">
        <Mail size={17} />
        <input
          id="email"
          type="email"
          inputMode="email"
          placeholder="you@example.com"
          value={email}
          onChange={(e) => update({ email: e.target.value })}
          onKeyDown={(e) => e.key === 'Enter' && valid && go('otp')}
        />
      </div>
      <Btn className="form-submit" iconEnd={ChevronRight} disabled={!valid} onClick={() => go('otp')}>
        Send code
      </Btn>
      <p className="legal-note">By continuing, you agree to the DropGrid terms.</p>
    </Screen>
  )
}

export function OtpScreen() {
  const { go, back, email } = useApp()
  const [digits, setDigits] = useState<string[]>(Array(6).fill(''))
  const [resendIn, setResendIn] = useState(42)
  const inputs = useRef<Array<HTMLInputElement | null>>([])

  useEffect(() => {
    if (resendIn <= 0) return
    const t = setInterval(() => setResendIn((s) => s - 1), 1000)
    return () => clearInterval(t)
  }, [resendIn])

  const setDigit = (i: number, v: string) => {
    const ch = v.replace(/\D/g, '').slice(-1)
    setDigits((d) => d.map((x, j) => (j === i ? ch : x)))
    if (ch && i < 5) inputs.current[i + 1]?.focus()
  }

  const complete = digits.every((d) => d !== '')
  const displayEmail = email || 'you@example.com'

  return (
    <Screen className="screen-auth">
      <TopBar title="Verify email" />
      <div className="form-copy">
        <Eyebrow>Step 2 / 2</Eyebrow>
        <h2>
          Check your
          <br />
          inbox.
        </h2>
        <p>
          We sent a 6-digit code to <strong>{displayEmail}</strong>.
        </p>
      </div>
      <div className="otp-row" onPaste={(e) => {
        const text = e.clipboardData.getData('text').replace(/\D/g, '').slice(0, 6)
        if (text.length > 1) {
          e.preventDefault()
          setDigits((d) => d.map((x, i) => text[i] ?? x))
          inputs.current[Math.min(text.length, 5)]?.focus()
        }
      }}>
        {digits.map((d, i) => (
          <input
            key={i}
            ref={(el) => {
              inputs.current[i] = el
            }}
            aria-label={`Code digit ${i + 1}`}
            inputMode="numeric"
            maxLength={2}
            placeholder="·"
            value={d}
            onChange={(e) => setDigit(i, e.target.value)}
            onKeyDown={(e) => {
              if (e.key === 'Backspace' && !digits[i] && i > 0) inputs.current[i - 1]?.focus()
            }}
          />
        ))}
      </div>
      <Btn
        className="form-submit"
        iconEnd={ShieldCheck}
        disabled={!complete}
        onClick={() => go('profile-setup')}
      >
        Verify code
      </Btn>
      <Btn variant="text" disabled={resendIn > 0} onClick={() => setResendIn(42)}>
        {resendIn > 0 ? `Resend code in 0:${String(resendIn).padStart(2, '0')}` : 'Resend code'}
      </Btn>
      <Btn variant="text" className="quiet" onClick={back}>
        Use a different email
      </Btn>
    </Screen>
  )
}

export function ProfileSetupScreen() {
  const { go, username, update } = useApp()
  const valid = username.trim().length >= 3

  return (
    <Screen className="screen-auth">
      <TopBar title="Create profile" />
      <div className="form-copy">
        <Eyebrow>Make it yours</Eyebrow>
        <h2>
          What should we
          <br />
          call you?
        </h2>
        <p>This is how you’ll appear on the leaderboard.</p>
      </div>
      <label className="field-label" htmlFor="username">
        Username
      </label>
      <div className="input-shell">
        <UserRound size={17} />
        <input
          id="username"
          value={username}
          maxLength={20}
          onChange={(e) => update({ username: e.target.value })}
          onKeyDown={(e) => e.key === 'Enter' && valid && enter()}
        />
      </div>
      <Btn className="form-submit" iconEnd={ChevronRight} disabled={!valid} onClick={enter}>
        Enter DropGrid
      </Btn>
      <Btn variant="text" onClick={enter}>
        Skip for now
      </Btn>
    </Screen>
  )

  function enter() {
    update({ guest: false })
    go('hub')
  }
}

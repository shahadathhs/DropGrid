'use client'

import { useState, type ReactNode } from 'react'
import { ChevronRight, LockKeyhole, Mail, Sparkles, UserRound } from 'lucide-react'
import { useApp } from '@/lib/app'
import { Btn, Eyebrow, Screen, TopBar } from '@/components/ui'

const EMAIL_RE = /^[^\s@]+@[^\s@]+\.[^\s@]+$/
// Usernames: 3 to 20 characters, letters, digits, or underscores (sync release spec).
const USERNAME_RE = /^[A-Za-z0-9_]{3,20}$/
const MIN_PASSWORD = 8

const isEmail = (v: string) => EMAIL_RE.test(v.trim())
const isPassword = (v: string) => v.length >= MIN_PASSWORD
const isUsername = (v: string) => USERNAME_RE.test(v)

// Prototype stand-in for POST /v1/auth/register and /v1/auth/login: a short delay and two
// placeholder outcomes. Emails starting "taken@" fail registration, "wrong@" fails sign-in.
const FAKE_REQUEST_MS = 700

// The sign-in response has no username yet, so the prototype derives one from the email.
function usernameFromEmail(email: string): string {
  const local = email.split('@')[0].replace(/[^A-Za-z0-9_]/g, '').slice(0, 20)
  return isUsername(local) ? local : 'player'
}

/*
 * Sign-up flow: AccountScreen -> EmailScreen (step 1) -> OtpScreen (step 2, password) ->
 * ProfileSetupScreen (step 3, username). Sign-in is a separate SignInScreen with email and
 * password only.
 *
 * The id "otp" is kept for the password step. The earlier design had a 6-digit code screen
 * here, but docs/README_PROJECT_OVERVIEW.md excludes "passwordless/OTP sign-in", so the
 * code screen is replaced by a password step in the same position of the flow.
 */

export function AccountScreen() {
  const { go, reset } = useApp()
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
        <p>Sync your best score, total lines, and games played across devices. Guest play stays free.</p>
      </div>
      <div className="stack">
        <Btn icon={Mail} onClick={() => go('email')}>
          Continue with email
        </Btn>
        <Btn variant="secondary" onClick={() => go('sign-in')}>
          Sign in
        </Btn>
        <Btn variant="text" onClick={() => reset('menu')}>
          Not now
        </Btn>
      </div>
      <p className="legal-note">Accounts use an email, a password, and a username. Sign-in never blocks your local save.</p>
    </Screen>
  )
}

export function EmailScreen() {
  const { go, email, update } = useApp()
  const [submitted, setSubmitted] = useState(false)
  const error = isEmail(email) ? null : 'Enter a valid email address.'

  return (
    <Screen className="screen-auth">
      <TopBar title="Create account" />
      <div className="form-copy">
        <Eyebrow>Step 1 of 3</Eyebrow>
        <h2>
          Where should
          <br />
          we reach you?
        </h2>
        <p>Your email signs you in on any device.</p>
      </div>
      <form
        className="stack auth-form"
        noValidate
        onSubmit={(e) => {
          e.preventDefault()
          setSubmitted(true)
          if (!error) go('otp')
        }}
      >
        <Field
          id="email"
          label="Email"
          icon={<Mail size={17} />}
          type="email"
          autoComplete="email"
          placeholder="you@example.com"
          value={email}
          onChange={(v) => update({ email: v })}
          error={submitted ? error : null}
        />
        <Btn type="submit" className="form-submit" iconEnd={ChevronRight} disabled={!isEmail(email)}>
          Continue
        </Btn>
      </form>
    </Screen>
  )
}

export function OtpScreen() {
  const { go, back, password, update } = useApp()
  const [submitted, setSubmitted] = useState(false)
  const error = isPassword(password) ? null : `Use at least ${MIN_PASSWORD} characters.`

  return (
    <Screen className="screen-auth">
      <TopBar title="Create account" />
      <div className="form-copy">
        <Eyebrow>Step 2 of 3</Eyebrow>
        <h2>
          Choose a
          <br />
          password.
        </h2>
        <p>Use at least {MIN_PASSWORD} characters.</p>
      </div>
      <form
        className="stack auth-form"
        noValidate
        onSubmit={(e) => {
          e.preventDefault()
          setSubmitted(true)
          if (!error) go('profile-setup')
        }}
      >
        <Field
          id="new-password"
          label="Password"
          icon={<LockKeyhole size={17} />}
          type="password"
          autoComplete="new-password"
          placeholder={`At least ${MIN_PASSWORD} characters`}
          value={password}
          onChange={(v) => update({ password: v })}
          error={submitted ? error : null}
        />
        <Btn type="submit" className="form-submit" iconEnd={ChevronRight}>
          Continue
        </Btn>
        <Btn type="button" variant="text" className="quiet" onClick={back}>
          Back
        </Btn>
      </form>
      <p className="legal-note">Forgot password is not available in this release.</p>
    </Screen>
  )
}

export function ProfileSetupScreen() {
  const { reset, back, email, password, username, update } = useApp()
  const [submitted, setSubmitted] = useState(false)
  const [loading, setLoading] = useState(false)
  const [serverError, setServerError] = useState<string | null>(null)
  const error = isUsername(username) ? null : 'Use 3 to 20 letters, digits, or underscores.'

  const submit = () => {
    setSubmitted(true)
    setServerError(null)
    if (error || loading) return
    setLoading(true)
    window.setTimeout(() => {
      setLoading(false)
      if (email.trim().toLowerCase().startsWith('taken@')) {
        setServerError('That email is already registered.')
        return
      }
      // The password is only needed for this request, so it leaves the app state here.
      update({ signedIn: true, email: email.trim(), password: '', username: username.trim() })
      reset('hub')
    }, FAKE_REQUEST_MS)
  }

  return (
    <Screen className="screen-auth">
      <TopBar title="Create account" />
      <div className="form-copy">
        <Eyebrow>Step 3 of 3</Eyebrow>
        <h2>
          What should we
          <br />
          call you?
        </h2>
        <p>This is how you’ll appear on the leaderboard.</p>
      </div>
      <form
        className="stack auth-form"
        noValidate
        onSubmit={(e) => {
          e.preventDefault()
          submit()
        }}
      >
        <Field
          id="username"
          label="Username"
          icon={<UserRound size={17} />}
          autoComplete="username"
          placeholder="3 to 20 characters"
          maxLength={20}
          value={username}
          onChange={(v) => update({ username: v })}
          error={submitted ? error : null}
        />
        {serverError && (
          <p className="form-error" role="alert">
            {serverError}
          </p>
        )}
        <Btn type="submit" className="form-submit" disabled={loading} aria-busy={loading}>
          {loading ? 'Creating account…' : 'Create account'}
        </Btn>
        <Btn type="button" variant="text" className="quiet" onClick={back}>
          Back
        </Btn>
      </form>
    </Screen>
  )
}

export function SignInScreen() {
  const { reset, back, update } = useApp()
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [submitted, setSubmitted] = useState(false)
  const [loading, setLoading] = useState(false)
  const [serverError, setServerError] = useState<string | null>(null)
  const emailError = isEmail(email) ? null : 'Enter a valid email address.'
  const passwordError = password ? null : 'Enter your password.'

  const submit = () => {
    setSubmitted(true)
    setServerError(null)
    if (emailError || passwordError || loading) return
    setLoading(true)
    window.setTimeout(() => {
      setLoading(false)
      if (email.trim().toLowerCase().startsWith('wrong@')) {
        setServerError('Incorrect email or password.')
        return
      }
      update({ signedIn: true, email: email.trim(), password: '', username: usernameFromEmail(email) })
      reset('hub')
    }, FAKE_REQUEST_MS)
  }

  return (
    <Screen className="screen-auth">
      <TopBar title="Sign in" />
      <div className="form-copy">
        <Eyebrow>Welcome back</Eyebrow>
        <h2>
          Sign in to
          <br />
          <em>sync.</em>
        </h2>
        <p>Your stats appear on this device once you sign in.</p>
      </div>
      <form
        className="stack auth-form"
        noValidate
        onSubmit={(e) => {
          e.preventDefault()
          submit()
        }}
      >
        <Field
          id="signin-email"
          label="Email"
          icon={<Mail size={17} />}
          type="email"
          autoComplete="email"
          placeholder="you@example.com"
          value={email}
          onChange={setEmail}
          error={submitted ? emailError : null}
        />
        <Field
          id="signin-password"
          label="Password"
          icon={<LockKeyhole size={17} />}
          type="password"
          autoComplete="current-password"
          value={password}
          onChange={setPassword}
          error={submitted ? passwordError : null}
        />
        {serverError && (
          <p className="form-error" role="alert">
            {serverError}
          </p>
        )}
        <Btn type="submit" className="form-submit" disabled={loading} aria-busy={loading}>
          {loading ? 'Signing in…' : 'Sign in'}
        </Btn>
        <Btn type="button" variant="text" className="quiet" onClick={back}>
          Back
        </Btn>
      </form>
      <p className="legal-note">Forgot password is not available in this release.</p>
    </Screen>
  )
}

function Field({
  id,
  label,
  icon,
  error,
  onChange,
  ...input
}: {
  id: string
  label: string
  icon: ReactNode
  error: string | null
  onChange: (value: string) => void
} & Omit<React.InputHTMLAttributes<HTMLInputElement>, 'onChange'>) {
  const errorId = `${id}-error`
  return (
    <div className="field">
      <label className="field-label" htmlFor={id}>
        {label}
      </label>
      <div className={`input-shell ${error ? 'invalid' : ''}`}>
        {icon}
        <input
          id={id}
          aria-invalid={error ? true : undefined}
          aria-describedby={error ? errorId : undefined}
          onChange={(e) => onChange(e.target.value)}
          {...input}
        />
      </div>
      {error && (
        <p id={errorId} className="field-error">
          {error}
        </p>
      )}
    </div>
  )
}

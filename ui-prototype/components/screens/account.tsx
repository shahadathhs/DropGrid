'use client'

import { useState, type ReactNode } from 'react'
import { Mail, LockKeyhole, UserRound, Sparkles } from 'lucide-react'
import { useApp } from '@/lib/app'
import { Btn, Eyebrow, Screen, TopBar } from '@/components/ui'

type Mode = 'signin' | 'register'

const EMAIL_RE = /^[^\s@]+@[^\s@]+\.[^\s@]+$/
const USERNAME_RE = /^[A-Za-z0-9_]{3,20}$/

const validate = {
  email: (v: string) => (EMAIL_RE.test(v.trim()) ? null : 'Enter a valid email address.'),
  password: (v: string) => (v.length >= 8 ? null : 'Use at least 8 characters.'),
  username: (v: string) => (USERNAME_RE.test(v) ? null : 'Use 3 to 20 letters, digits, or underscores.'),
}

export function AccountScreen() {
  const { reset, update } = useApp()
  const [mode, setMode] = useState<Mode>('signin')
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [username, setUsername] = useState('')
  const [submitted, setSubmitted] = useState(false)
  const [loading, setLoading] = useState(false)
  const [serverError, setServerError] = useState<string | null>(null)

  const register = mode === 'register'
  const errors = {
    email: validate.email(email),
    password: validate.password(password),
    username: register ? validate.username(username) : null,
  }
  const hasErrors = Object.values(errors).some(Boolean)

  const switchMode = (next: Mode) => {
    setMode(next)
    setSubmitted(false)
    setServerError(null)
  }

  const submit = () => {
    setSubmitted(true)
    setServerError(null)
    if (hasErrors || loading) return
    setLoading(true)
    // Visual prototype: the server call is faked with a short delay and a
    // hard-coded outcome. Emails starting "taken@" or "wrong@" show the
    // server-error placeholder.
    window.setTimeout(() => {
      setLoading(false)
      const local = email.trim().toLowerCase()
      if (register && local.startsWith('taken@')) {
        setServerError('That email is already registered.')
        return
      }
      if (!register && local.startsWith('wrong@')) {
        setServerError('Incorrect email or password.')
        return
      }
      update({ signedIn: true, email: email.trim(), username: register ? username : 'Jordan' })
      reset('hub')
    }, 700)
  }

  return (
    <Screen className="screen-auth">
      <TopBar title={register ? 'Create account' : 'Sign in'} />
      <div className="form-copy">
        <Eyebrow>Optional account</Eyebrow>
        <h2>
          {register ? (
            <>
              Save your
              <br />
              <em>progress.</em>
            </>
          ) : (
            <>
              Welcome
              <br />
              <em>back.</em>
            </>
          )}
        </h2>
        <p>Sync your best score, lines, and games across devices. Guest play always stays free.</p>
      </div>

      <div className="segmented" role="group" aria-label="Account mode">
        <button type="button" aria-pressed={!register} onClick={() => switchMode('signin')}>
          Sign in
        </button>
        <button type="button" aria-pressed={register} onClick={() => switchMode('register')}>
          Create account
        </button>
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
          id="email"
          label="Email"
          icon={<Mail size={17} />}
          type="email"
          autoComplete="email"
          placeholder="you@example.com"
          value={email}
          onChange={setEmail}
          error={submitted ? errors.email : null}
        />
        <Field
          id="password"
          label="Password"
          icon={<LockKeyhole size={17} />}
          type="password"
          autoComplete={register ? 'new-password' : 'current-password'}
          placeholder="At least 8 characters"
          value={password}
          onChange={setPassword}
          error={submitted ? errors.password : null}
        />
        {register && (
          <Field
            id="username"
            label="Username"
            icon={<UserRound size={17} />}
            autoComplete="username"
            placeholder="3 to 20 characters"
            maxLength={20}
            value={username}
            onChange={setUsername}
            error={submitted ? errors.username : null}
          />
        )}

        {serverError && (
          <p className="form-error" role="alert">
            {serverError}
          </p>
        )}

        <Btn type="submit" className="form-submit" disabled={loading} aria-busy={loading}>
          {loading ? (register ? 'Creating account…' : 'Signing in…') : register ? 'Create account' : 'Sign in'}
        </Btn>
      </form>

      <p className="legal-note">
        <Sparkles size={12} /> Accounts are optional. Your local save is never blocked by sign-in.
      </p>
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

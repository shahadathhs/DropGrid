'use client'

import { ArrowLeft, type LucideIcon } from 'lucide-react'
import type { ReactNode } from 'react'
import { useApp } from '@/lib/app'

export function Eyebrow({ children }: { children: ReactNode }) {
  return <p className="eyebrow">{children}</p>
}

type ButtonVariant = 'primary' | 'secondary' | 'ghost' | 'text'

export function Btn({
  variant = 'primary',
  icon: Icon,
  iconEnd: IconEnd,
  className = '',
  ...props
}: React.ButtonHTMLAttributes<HTMLButtonElement> & {
  variant?: ButtonVariant
  icon?: LucideIcon
  iconEnd?: LucideIcon
}) {
  return (
    <button className={`btn btn-${variant} ${className}`} {...props}>
      {Icon && <Icon size={17} data-icon="inline-start" />}
      {props.children}
      {IconEnd && <IconEnd size={17} data-icon="inline-end" />}
    </button>
  )
}

export function IconBtn({
  label,
  icon: Icon,
  ...props
}: React.ButtonHTMLAttributes<HTMLButtonElement> & { label: string; icon: LucideIcon }) {
  return (
    <button className="icon-btn" aria-label={label} {...props}>
      <Icon size={17} />
    </button>
  )
}

export function TopBar({ title, action }: { title: string; action?: ReactNode }) {
  const { back } = useApp()
  return (
    <header className="topbar">
      <IconBtn label="Go back" icon={ArrowLeft} onClick={back} />
      <strong>{title}</strong>
      {action ?? <span className="top-spacer" />}
    </header>
  )
}

export function Screen({ children, className = '' }: { children: ReactNode; className?: string }) {
  return <section className={`screen screen-pad ${className}`}>{children}</section>
}

export function Stat({ label, value }: { label: string; value: string }) {
  return (
    <div className="stat">
      <span>{label}</span>
      <strong>{value}</strong>
    </div>
  )
}

export function Avatar({ label = 'JD' }: { label?: string }) {
  return <div className="avatar">{label}</div>
}

export function Brand() {
  return (
    <div className="brand">
      <span className="brand-mark">
        <span />
        <span />
        <span />
        <span />
      </span>
      DropGrid
    </div>
  )
}

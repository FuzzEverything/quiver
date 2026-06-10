"""
Lesson: Kolmogorov's axioms
Topic:  foundations
Run:    uv run python lesson.py
"""

from dataclasses import dataclass
from enum import Enum, auto
from typing import FrozenSet


# ---------------------------------------------------------------------------
# Types
# ---------------------------------------------------------------------------


@dataclass(frozen=True)
class Flow:
    """One completed connection (Zeek conn.log-style fields)."""

    orig_bytes: int
    resp_bytes: int
    duration_sec: float


class FlowClass(Enum):
    """Elementary outcomes in sample space Omega."""

    BENIGN = auto()
    MALWARE = auto()
    UNKNOWN = auto()


type Event = FrozenSet[FlowClass]


def event(outcomes: list[FlowClass]) -> Event:
    """Build an event from outcomes, removing duplicates."""
    return frozenset(outcomes)


class Probability:
    """Probability in [0, 1] with fixed decimal display."""

    def __init__(self, value: float) -> None:
        self.value = value

    def __add__(self, other: "Probability") -> "Probability":
        return Probability(self.value + other.value)

    def __sub__(self, other: "Probability") -> "Probability":
        return Probability(self.value - other.value)

    def __ge__(self, other: object) -> bool:
        if isinstance(other, Probability):
            return self.value >= other.value
        return NotImplemented

    def __abs__(self) -> "Probability":
        return Probability(abs(self.value))

    def __repr__(self) -> str:
        return f"{self.value:.2f}"


# ---------------------------------------------------------------------------
# Measure
# ---------------------------------------------------------------------------

ATOMIC_PROBABILITY: dict[FlowClass, Probability] = {
    FlowClass.BENIGN: Probability(0.9),
    FlowClass.MALWARE: Probability(0.05),
    FlowClass.UNKNOWN: Probability(0.05),
}


def atomic_probability(outcome: FlowClass) -> Probability:
    """P({outcome}) for each outcome in Omega."""
    return ATOMIC_PROBABILITY[outcome]


def probability_of(e: Event) -> Probability:
    """P(E) = sum of atomic probabilities over outcomes in E."""
    total = 0.0
    for outcome in e:
        total += atomic_probability(outcome).value
    return Probability(total)


SAMPLE_SPACE: Event = event(list(FlowClass))
SUSPICIOUS: Event = event([FlowClass.MALWARE, FlowClass.UNKNOWN])


# ---------------------------------------------------------------------------
# Axiom checks
# ---------------------------------------------------------------------------


@dataclass(frozen=True)
class AxiomChecks:
    all_non_negative: bool
    sums_to_one: bool
    additive_when_disjoint: bool


def check_disjoint_additivity(a: Event, b: Event) -> bool:
    disjoint = a.isdisjoint(b)
    if not disjoint:
        return True
    union = a | b
    lhs = probability_of(union)
    rhs = probability_of(a) + probability_of(b)
    return abs(lhs - rhs).value < 1e-6


def run_axiom_checks() -> AxiomChecks:
    return AxiomChecks(
        all_non_negative=all(atomic_probability(c) >= Probability(0) for c in FlowClass),
        sums_to_one=abs(probability_of(SAMPLE_SPACE) - Probability(1)).value < 1e-6,
        additive_when_disjoint=check_disjoint_additivity(
            event([FlowClass.BENIGN]), event([FlowClass.MALWARE])
        ),
    )


# ---------------------------------------------------------------------------
# Classification
# ---------------------------------------------------------------------------


def classify_flow(flow: Flow) -> FlowClass:
    if flow.duration_sec <= 0 or flow.orig_bytes + flow.resp_bytes == 0:
        return FlowClass.UNKNOWN
    if flow.orig_bytes < 2000 and flow.resp_bytes < 2000:
        return FlowClass.MALWARE
    return FlowClass.BENIGN


DEMO_FLOWS: list[tuple[str, Flow]] = [
    ("browser HTTPS session", Flow(12000, 180000, 45)),
    ("beacon-like check-in", Flow(400, 380, 60)),
    ("failed / no payload", Flow(0, 0, 0)),
]


# ---------------------------------------------------------------------------
# Printing
# ---------------------------------------------------------------------------


def print_header(title: str) -> None:
    print()
    print(title)
    print("-" * len(title))


def format_flow(flow: Flow) -> str:
    return (
        f"orig={flow.orig_bytes} resp={flow.resp_bytes} "
        f"dur={flow.duration_sec:.0f}s"
    )


def print_atomic_weights() -> None:
    print_header("Atomic probabilities P({class})")
    for outcome in FlowClass:
        print(f"  {outcome.name:<7}  {atomic_probability(outcome)}")


def print_axiom_results() -> None:
    checks = run_axiom_checks()
    print_header("Kolmogorov axiom checks")
    print(f"  Non-negativity:        {checks.all_non_negative}")
    print(f"  Normalization:         {checks.sums_to_one}")
    print(f"  Disjoint additivity:   {checks.additive_when_disjoint}")


def print_flow_example(name: str, flow: Flow) -> None:
    outcome = classify_flow(flow)
    p = probability_of(event([outcome]))
    print(
        f"  {name:<24}  {format_flow(flow)}  ->  "
        f"{outcome.name:<7}  (P({{{outcome.name}}}) = {p})"
    )


def print_compound_events() -> None:
    print_header("Compound events (disjoint unions)")
    print(f"  P(malware or unknown) = {probability_of(SUSPICIOUS)}")


def main() -> None:
    print_atomic_weights()
    print_axiom_results()
    print_header("Classify example flows")
    for name, flow in DEMO_FLOWS:
        print_flow_example(name, flow)
    print_compound_events()


if __name__ == "__main__":
    main()

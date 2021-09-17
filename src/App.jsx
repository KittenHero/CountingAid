import styles from "./App.module.css";
import { onCleanup, createSignal } from "solid-js";
import { hsluvToHex } from "hsluv";

function randintRange(min, max) {
  return min + (Math.random() * (max - min) | 0);
}

function Counter() {
  const [count, setCount] = createSignal(0);
  const lightness = randintRange(0, 100);
  const color = hsluvToHex([randintRange(0, 360), randintRange(0, 100), lightness]);
  const textColor = lightness >= 50 ? "black" : "white";
  return (
    <div>
      <button
       class={styles.counter}
       style={{ "--color": color, "--text-color": textColor }}
       onClick={() => setCount(count => count + 1)}>
        {count}
      </button>
    </div>
  );
}

function App() {
  const [counters, setCounters] = createSignal([Counter()]);

  return (
    <div class={styles.App}>
      <button class={styles.createButton} onClick={() => setCounters(counters => counters.concat([Counter()]))}>+</button>
      <main class={styles.main}>
       {counters}
      </main>
    </div>
  );
}

export default App;

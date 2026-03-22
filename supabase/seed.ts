/**
 * ! Executing this script will delete all data in your database and seed it with 10 buckets_vectors.
 * ! Make sure to adjust the script to your needs.
 * Use any TypeScript runner to run this script, for example: `npx tsx seed.ts`
 * Learn more about the Seed Client by following our guide: https://docs.snaplet.dev/seed/getting-started
 */
import { createSeedClient, SeedClient } from "@snaplet/seed";
import { copycat } from "@snaplet/copycat";

function getRandomInt(min: number, max: number) {
  min = Math.ceil(min);
  max = Math.floor(max);
  return Math.floor(Math.random() * (max - min + 1)) + min;
}

const count = {
  users: 100,
  unions: 200,
  messages: 100,
}

// const full = async (seed: SeedClient) => {
//   const { profiles } = await seed.profiles((x) => x(count.users, {
//     username: (x) => copycat.username(x.seed)
//   }));

//   const { unions } = await seed.unions((x) =>
//     x(count.unions, ({ index }) => ({
//       name: (x) => copycat.streetName(x.seed),
//       creator_id: profiles[index % profiles.length].id,
//     }))
//   );

//   await seed.union_members((x) =>
//     x(20, ({ index }) => ({
//       union_id: unions[index % unions.length].id,
//       user_id: profiles[index % profiles.length].id,
//     }))
//   );

//   await seed.public_messages((x) =>
//     x(count.messages, ({ index }) => ({
//       union_id: unions[index % unions.length].id,
//       user_id: profiles[index % profiles.length].id,
//       content: (x) => copycat.sentence(x.seed, { min: 4, max: getRandomInt(6, 20) }),
//     }))
//   );
// }


const main = async () => {
  const seed = await createSeedClient({ dryRun: true });

  await seed.$resetDatabase();

  const startDate = new Date(2025, 0, 1, 0, 0);
  let incrementedMinutes = 0;

  const { unions } = await seed.unions((x) =>
    x(count.unions, ({ index }) => ({
      name: (x) => copycat.streetName(x.seed),
    }))
  );

  await seed.public_messages((ctx) => ctx(count.messages, {
    // Incrementing content number
    content: () => {
      return (incrementedMinutes + 1).toString();
    },
    // Incrementing timestamp by 1 minute per record
    created_at: () => {
      const nextDate = new Date(startDate.getTime() + incrementedMinutes * 60000);
      incrementedMinutes++; // Move to the next minute for the next row
      return nextDate.toISOString();
    },
  }), { connect: { unions } })

  process.exit();
};

main();

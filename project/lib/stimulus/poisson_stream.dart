// https://support.minitab.com/en-us/minitab-express/1/help-and-how-to/basic-statistics/probability-distributions/supporting-topics/distributions/poisson-distribution/
// Poisson is commonly used for modelling the number of occurrences
// of an event within a particular time interval.
// For example, we may want an average of 20 spikes to occur within
// a 1 sec interval.
// Note: where the spikes occur within the interval is random, but
// we expect to average 20 spikes within that interval.

// What is rate of occurrence?
// The rate of occurrence equals the mean (λ) divided by the dimension
// of your observation space (interval). It is useful for comparing Poisson
// counts collected in different observation spaces.
// For example, Switchboard A receives 50 telephone calls in 5 hours,
// and Switchboard B receives 80 calls in 10 hours.
// You cannot directly compare these values because their observation
// spaces are different.
// You must calculate the occurrence rate to compare these counts.
// The rate for Switchboard A is (50 calls / 5 hours) = 10 calls/hour.
// The rate for Switchboard B is (80 calls / 10 hours) = 8 calls/hour.

// Generating:
// If you have a Poisson process with rate parameter
// L (meaning that, long term, there are L arrivals per second),
// then the inter-arrival times are exponentially distributed with
// mean 1/L.
// So the PDF is f(t) = -L*exp(-Lt),
// and the CDF is F(t) = Prob(T < t) = 1 - exp(-Lt).
// So your problem changes to: how do I generate a random number t
// with distribution F(t) = 1 - \exp(-Lt)?

// Assuming the language you are using has a function (let's call it rand())
// to generate random numbers uniformly distributed between 0 and 1,
// the inverse CDF technique reduces to calculating: -log(rand()) / L

import 'dart:math';

import 'package:d4_random/d4_random.dart';

import '../model/neuron_properties.dart';
import 'ibit_stream.dart';

// class CustomPoissonDistribution extends PoissonDistribution {
//   // Lambda is the number of events within an interval
//   const CustomPoissonDistribution(super.lambda);

//   // If lamba > 745 then divide lamba by 2
//   @override
//   int sample({Random? random}) {
//     const uniform = UniformDistribution.standard();
//     var i = 0, b = 1.0;

//     if (lambda <= 750) {
//       while (b >= exp(-lambda)) {
//         b *= uniform.sample(random: random);
//         i++;
//       }
//       return i - 1;
//     }

//     var lambert = lambda / 2;
//     while (b >= exp(-lambert)) {
//       b *= uniform.sample(random: random);
//       i++;
//     }
//     i--;

//     var j = 0, c = 1.0;
//     while (c >= exp(-lambert)) {
//       c *= uniform.sample(random: random);
//       j++;
//     }
//     j--;

//     return (i + j) ~/ 2;
//   }
// }

class CustomPoissonDistribution {
  late num lambda;
  late num Function() randoP;

  CustomPoissonDistribution();

  factory CustomPoissonDistribution.create(num lambda) {
    CustomPoissonDistribution cd = CustomPoissonDistribution()
      ..lambda = lambda
      ..randoP = randomPoisson(lambda);
    return cd;
  }

  num sample() {
    return randoP();
  }
}

class PoissonStream implements IBitStream {
  late CustomPoissonDistribution poisson;

  // The Interspike interval (ISI) is a counter
  // When the counter reaches 0 a spike is placed on the output
  // for single pass.
  int isi = 0;

  // λ is the shape parameter which indicates the 'average' number of
  // events in the given time interval
  double averagePerInterval = 0.0;

  int seed = 0;
  late Random rando;

  int outputSpike = 0;

  PoissonStream(this.btype);

  factory PoissonStream.create(int seed, double averagePerInterval) {
    PoissonStream ps = PoissonStream(BitStreamType.noise)
      ..seed = seed
      .. // lambda comes from SimModel.json
          averagePerInterval = averagePerInterval // Lambda
      ..reset();

    return ps;
  }

  @override
  int output() {
    return outputSpike;
  }

  @override
  reset() {
    rando = Random(seed);
    poisson = CustomPoissonDistribution.create(averagePerInterval);
    isi = next();
    outputSpike = 0;
  }

  @override
  step() {
    if (isi <= 0) {
      // Time to generate a spike
      isi = next();
      outputSpike = 1;
    } else {
      isi--;
      outputSpike = 0;
    }
  }

  @override
  update(NeuronProperties model) {
    averagePerInterval = model.noiseLambda;
  }

  // Create an event per interval of time, for example, spikes in a 1 sec span.
  // A firing rate given in rate/ms, for example, 0.2 in 1ms (0.2/1)
  // or 200 in 1sec (200/1000ms)
  int next() {
    int r = poisson.sample().toInt();
    // double rand = rando.nextDouble();
    // int offset = rando.nextInt(150);
    // if (rand < 0.5) {
    //   r -= offset;
    // } else {
    //   r += offset;
    // }
    return r;

    // isiF := -math.Log(1.0-r) / averagePerInterval
    // fmt.Print(isiF, "  ")
    // return int64(math.Round(isiF))
  }

  @override
  configure({int? seed, double? lambda}) {
    this.seed = seed ?? 100;
    averagePerInterval = lambda ?? 100.0;
  }

  @override
  BitStreamType btype;
}

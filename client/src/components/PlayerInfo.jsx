import ReactTooltip from "react-tooltip";
import styles from "../styles";

const healthPoints = 25;

const PlayerInfo = ({ player, playerIcon, mt }) => {
  return (
    <div className={`${styles.flexCenter} ${mt ? 'mt-4' : 'mb-4'}`}>
      <img data-for={`Player-${mt ? '1' : '2'}`} data-tip src={playerIcon} alt="player2" className="w-14 h-14 object-contain rounded-full" />

      <div className={styles.playerHealth}
        data-for={`Health-${mt ? '1' : '2'}`}
        data-tip={`Health: ${player?.health}`}
      >
        
      </div>
    </div>
  )
};

export default PlayerInfo;
